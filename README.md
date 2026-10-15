# GCP Multi-Environment Microservices Infrastructure with Terraform

This repository is a learning-oriented, production-shaped starter for **Test**, **Dev**, and **Prod** on Google Cloud.

## Architecture

- One GCP project per environment is the recommended design: `test`, `dev`, and `prod`.
- Each environment has its own custom-mode VPC and one regional subnet:
  - Test: `10.10.0.0/24`
  - Dev: `10.20.0.0/24`
  - Prod: `10.30.0.0/24`
- Four example Cloud Run services per environment: `catalog-api`, `orders-api`, `payments-api`, and `notifications-api`.
- Each Cloud Run service uses **Direct VPC egress** to the environment subnet for private-range egress. Multiple Cloud Run services can use the same subnet.
- Each service runs with its own runtime service account and no `allUsers` invoker grant. Therefore the services are not anonymously invokable by default.
- Cloud Run uses the public Google sample image `us-docker.pkg.dev/cloudrun/container/hello` as a placeholder for each service. Replace it with your actual service images when application code exists. These placeholders demonstrate infrastructure deployment, not real order/payment/catalog logic.
- Each environment uses a separate GCS state bucket. GCS provides Terraform state locking; bucket object versioning is enabled for recovery.

## Important: GCP state backend vs AWS S3/DynamoDB

S3 and DynamoDB are AWS services. For infrastructure managed on Google Cloud, this repository uses the **Terraform GCS backend** (Google Cloud Storage). The GCS backend supports state locking and should use a pre-created bucket with Object Versioning enabled. Do not add an AWS DynamoDB lock table to this GCP-only design.

## Requirements

- Terraform 1.6 or newer.
- Google Cloud CLI (`gcloud`).
- ADC credentials: `gcloud auth application-default login`.
- A GCP project with billing enabled and permissions to enable APIs, create VPCs/subnets, create Cloud Run services/service accounts and manage project services.
- For the full company-style isolation, three existing GCP projects and permission to deploy into each. Test uses the existing project ID `devops-504813` as a starter default; replace it if that is not your intended Test project.

## 1. Create the remote state buckets (bootstrap)

The backend bucket must exist **before** a Terraform root can initialize using it. Bootstrap creates four dedicated buckets in the state project: one for its own state plus one each for Test, Dev, and Prod. The bootstrap configuration initially uses local state because it must create the remote state buckets before it can use one.

```bash
cd bootstrap-state
gcloud auth application-default login
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan before applying. The state buckets have Object Versioning, uniform bucket-level access, Public Access Prevention and `prevent_destroy` protection.

Bucket names must be globally unique. The default prefix in `bootstrap-state/variables.tf` is `devops-504813-iac-20261015`. If a bucket name is already taken, create `bootstrap-state/terraform.tfvars` with a different unique prefix, for example:

```hcl
state_project_id = "devops-504813"
region           = "asia-south1"
bucket_prefix    = "replace-with-your-unique-lowercase-prefix"
```

The bucket name format is `<bucket_prefix>-<environment>-tfstate`. Record the bucket names from `terraform output`.

To store the bootstrap configuration's own state remotely too, copy `bootstrap-state/backend.tf.example` to `bootstrap-state/backend.tf`, update its bucket name to the actual `<prefix>-bootstrap-tfstate` bucket, and run:

```bash
terraform init -migrate-state
```

Confirm the migration when prompted. Afterward, bootstrap state is stored in GCS as well. Keep any generated local state backup secured and out of Git.

**Update the hardcoded `bucket` value in each `environments/<env>/backend.tf` to match the actual bucket name created by bootstrap.** Backend configuration cannot interpolate normal Terraform variables.

For a mature company setup, put these buckets in a dedicated platform/state project with restricted IAM—not in the same project as an environment. The default existing project is only to make the first lab easier to start.

## 2. Configure environment project IDs

Test has a starter `terraform.tfvars` targeting `devops-504813`.

For Dev and Prod, create `terraform.tfvars` from each `terraform.tfvars.example` and replace the project ID with a real, existing project ID. Project IDs are globally unique and cannot be freely invented in Terraform variables; create the projects through your organization or Google Cloud Console first and enable billing. Avoid using the same project for Test, Dev and Prod in a production-style design.

If you do not yet have three projects, deploy **Test only** first. You may temporarily test namespaced VPCs/services in one project, but that is not equivalent to project-level isolation and should not be treated as production segregation.

## 3. Deploy Test first

After the state bucket exists and `environments/test/backend.tf` is configured to its exact name:

```bash
cd ../environments/test
terraform init
terraform fmt -recursive
terraform validate
terraform plan
```

Inspect the plan. It should create one VPC, one subnet, the required API activations, four service accounts, and four Cloud Run services (plus related service resources). If correct:

```bash
terraform apply
```

Do not use `-auto-approve` while learning. Inspect each plan before applying.

## 4. Deploy Dev and Prod

Once their projects exist, copy `terraform.tfvars.example` to `terraform.tfvars`, set the real project ID and check the environment CIDR. Then initialize/apply each folder independently:

```bash
cd ../dev
terraform init
terraform validate
terraform plan
terraform apply

cd ../prod
terraform init
terraform validate
terraform plan
terraform apply
```

Prod Cloud Run services have deletion protection enabled. To intentionally destroy a Prod service, first change its protection setting in code, apply that change, and only then plan destruction. Do not do this as a routine cleanup step.

## Network notes

- Every environment gets one VPC and one subnet. CIDRs are non-overlapping to make future peering/VPN options easier.
- Cloud Run is a serverless service, not a VM that is permanently located on a subnet. Direct VPC egress allows a Cloud Run revision to use addresses from the configured subnet for traffic into private IP ranges.
- The starter uses `PRIVATE_RANGES_ONLY`. Public destinations do not get routed through the VPC by this setting.
- There is no blanket ingress firewall allow rule and no anonymous Cloud Run invoker binding. Add an authenticated entry point/API gateway and explicit service-to-service IAM as a separate lesson.
- Runtime service accounts have no extra project roles by default. Grant only the roles each service needs, such as a specific Secret Manager or database permission, when you add real applications.
- A VPC/subnet by itself does not make a service-to-service application. The sample images are identical; replace them with application-specific images and configure service URLs/permissions to model actual dependencies.

## Cost and cleanup

Cloud Run can scale to zero, but deployed services, API usage, logs, networking and other resources may incur charges. Check current pricing before applying. Deploy Test first and destroy the Test environment when finished if you no longer need it:

```bash
cd environments/test
terraform plan -destroy
terraform destroy
```

Review the destroy plan carefully. Do not run the command from the wrong environment. The state buckets are separate and protected by their bootstrap lifecycle rule.




