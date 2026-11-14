#!/usr/bin/env bash
# deploy_lifecycle.sh
# Creates the lab bucket, uploads sample files, and applies the Glacier lifecycle rule.
#
# Usage:  bash scripts/deploy_lifecycle.sh <path-to-sample-data> [policy-file]
# Example: bash scripts/deploy_lifecycle.sh ./sample-data
#          bash scripts/deploy_lifecycle.sh ./sample-data policy/lifecycle_glacier_small_objects.json
set -euo pipefail

BUCKET="${BUCKET:-labglacier-lwere}"
REGION="${REGION:-us-east-2}"
SAMPLE_DIR="${1:?Usage: $0 <path-to-sample-data> [policy-file]}"
POLICY_FILE="${2:-$(dirname "$0")/../policy/lifecycle_glacier.json}"

[ -d "$SAMPLE_DIR" ]  || { echo "Sample data folder not found: $SAMPLE_DIR"; exit 1; }
[ -f "$POLICY_FILE" ] || { echo "Policy file not found: $POLICY_FILE"; exit 1; }
command -v aws >/dev/null || { echo "AWS CLI is not installed."; exit 1; }

echo "==> Creating bucket s3://$BUCKET in $REGION"
if aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "    Bucket already exists, skipping creation."
else
  aws s3api create-bucket \
    --bucket "$BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
fi

echo "==> Uploading sample files from $SAMPLE_DIR"
aws s3 cp "$SAMPLE_DIR" "s3://$BUCKET/" --recursive

echo "==> Applying lifecycle rule from $POLICY_FILE"
aws s3api put-bucket-lifecycle-configuration \
  --bucket "$BUCKET" \
  --lifecycle-configuration "file://$POLICY_FILE"

echo "==> Lifecycle configuration now on the bucket:"
aws s3api get-bucket-lifecycle-configuration --bucket "$BUCKET"

echo
echo "Done. Lifecycle rules run once per day; re-check in 24-48 hours with:"
echo "  bash scripts/verify_storage_class.sh"
