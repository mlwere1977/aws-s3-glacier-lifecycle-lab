# AWS S3 Lifecycle Policy: Automated Archiving to Glacier Flexible Retrieval

![AWS S3](https://img.shields.io/badge/AWS-S3-569A31?style=flat-square&logo=amazon-s3&logoColor=white)
![Glacier](https://img.shields.io/badge/Storage-Glacier%20Flexible%20Retrieval-1E3A8A?style=flat-square)
![Region](https://img.shields.io/badge/Region-us--east--2%20(Ohio)-FF9900?style=flat-square)
![Course](https://img.shields.io/badge/Course-CS%2079B%20Cloud%20Computing-1E3A8A?style=flat-square)

## Project Overview
This repository documents how to create an **Amazon S3 bucket**, upload sample data, and attach an **S3 Lifecycle rule** that automatically transitions objects from the **S3 Standard** storage class to **S3 Glacier Flexible Retrieval** for low-cost archival.

* **Author:** ML
* **Course:**  Cloud Infrastructure & Database Administration
* **Assignment:** Assignment 3 — S3 → Glacier
* **Bucket:** `labglacier-lwere` (US East, Ohio — `us-east-2`)
* **Lifecycle rule:** `lifecycle_glacier` (entire bucket, transition at Day 1)

---

## Repository Structure

```text
aws-s3-glacier-lifecycle-lab/
├── README.md                              # Project overview and deployment guide
├── .gitignore                             # Excludes keys, credentials, and OS artifacts
├── publish-lab.ps1                        # One-step "create repo and push" script (Windows)
├── policy/
│   ├── lifecycle_glacier.json             # Lifecycle rule as used in the lab (Day 1 → Glacier)
│   └── lifecycle_glacier_small_objects.json  # Variant that also archives objects under 128 KB
├── scripts/
│   ├── deploy_lifecycle.sh                # AWS CLI: create bucket, upload files, apply the rule
│   └── verify_storage_class.sh            # AWS CLI: confirm objects moved to GLACIER
└── docs/
    ├── LAB_REPORT.md                      # Walkthrough, results, and lessons learned
    └── screenshots/
        ├── 01_s3_bucket_created.png
        ├── 02_upload_succeeded.png
        ├── 03_bucket_objects_standard_class.png
        ├── 04_lifecycle_rule_created.png
        ├── 05_policy_summary.png
        └── 06_executed_policy_storage_class.png
```

---

## Architecture Summary

| Component | Configuration |
| :--- | :--- |
| **Service** | Amazon S3 (general purpose bucket) |
| **Region** | US East (Ohio) — `us-east-2` |
| **Bucket name** | `labglacier-lwere` |
| **Sample data** | 8 objects (~167.9 KB): one CSV plus a small static website (`website/*.htm`, `website/images/*.jpg`) |
| **Initial storage class** | S3 Standard |
| **Lifecycle rule** | `lifecycle_glacier` — scope: entire bucket, status: Enabled |
| **Transition action** | Current versions move to **Glacier Flexible Retrieval** at **Day 1** after creation |
| **Noncurrent version / expiration actions** | None defined |

---

## Quick Start

### Option A: AWS Console (what was done in the lab)
1. **Create the bucket:** S3 → *Create bucket* → name `labglacier-lwere` in `us-east-2`.
2. **Upload sample files:** Open the bucket → *Upload* → add the CSV and the `website/` folder. Confirm all 8 files show *Succeeded*.
3. **Create the lifecycle rule:** bucket → *Management* → *Lifecycle rules* → *Create lifecycle rule*.
   * Name: `lifecycle_glacier`
   * Scope: apply to all objects in the bucket
   * Action: *Move current versions of objects between storage classes*
   * Transition to **Glacier Flexible Retrieval** after **1** day
4. **Capture the required screenshots:** the policy summary, then the bucket's object list after the rule runs and the storage class changes.

### Option B: AWS CLI (repeatable)
```bash
aws configure                                # one-time setup (never commit keys)
bash scripts/deploy_lifecycle.sh ./sample-data   # create bucket, upload, apply lifecycle rule
bash scripts/verify_storage_class.sh             # check storage class of each object
```

---

## Important Note: the 128 KB Minimum Object Size

S3 does not transition objects smaller than **128 KB** to Glacier storage classes by default (the console shows *"Default minimum object size for transitions: All storage classes 128K"*). Every object in this lab is under 128 KB (the largest, `banner.jpg`, is 87.6 KB), so with the default setting they may stay in **Standard** after the rule runs.

To archive small objects anyway, use [`policy/lifecycle_glacier_small_objects.json`](policy/lifecycle_glacier_small_objects.json), which sets an explicit minimum object size on the rule. See the [lab report](docs/LAB_REPORT.md#troubleshooting-objects-still-show-standard) for details. Also note that very small objects cost more to archive than to leave in Standard, since Glacier adds per-object metadata overhead. This is fine for a lab but not a good production pattern.

---

## Cost & Clean-Up
* Lifecycle rules are evaluated **once per day**, so transitions can take 24–48 hours to appear.
* Glacier Flexible Retrieval has a 90-day minimum storage duration, so early deletion is billed.
* When finished, remove the lab resources to avoid charges:
  ```bash
  aws s3 rm s3://labglacier-lwere --recursive
  aws s3api delete-bucket --bucket labglacier-lwere --region us-east-2
  ```

---

## Security Notes
* AWS account IDs were **redacted** from the screenshots in this repository.
* `.gitignore` blocks `*.pem`, `*.key`, `.env`, and similar files. Never commit access keys or credentials.
* Use IAM roles or short-lived credentials for CLI access rather than long-lived root keys.

---

## Deliverables
Full step-by-step evidence, including bucket creation, upload status, the lifecycle policy summary, and the post-run storage class, is documented in [`docs/LAB_REPORT.md`](docs/LAB_REPORT.md).
