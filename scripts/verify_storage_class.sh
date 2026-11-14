#!/usr/bin/env bash
# verify_storage_class.sh
# Lists every object in the lab bucket with its storage class.
# Objects that have transitioned show GLACIER; untransitioned objects show STANDARD.
set -euo pipefail

BUCKET="${BUCKET:-labglacier-lwere}"
REGION="${REGION:-us-east-2}"

command -v aws >/dev/null || { echo "AWS CLI is not installed."; exit 1; }

echo "Storage class of objects in s3://$BUCKET"
aws s3api list-objects-v2 \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --query 'Contents[].{Key:Key,SizeBytes:Size,StorageClass:StorageClass}' \
  --output table
