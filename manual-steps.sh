#bin bash
GOOGLE_USER="quantum"

# Set up the environment
export TF_VAR_org_id="org_id"
export TF_VAR_billing_account="billing_id"
export TF_ADMIN=${GOOGLE_USER}-terraform-admin
export TF_CREDS=~/.config/gcloud/${GOOGLE_USER}-terraform-admin.json

## Set the name of the project you want to create and the region you want to create the resources in:
export TF_VAR_project_name=${GOOGLE_USER}-test
export TF_VAR_region=us-east4

# Create the Terraform Admin Project
## Create a new project and link it to your billing account:
gcloud projects create ${TF_ADMIN} \
  --organization ${TF_VAR_org_id} \
  --set-as-default

gcloud beta billing projects link ${TF_ADMIN} \
  --billing-account ${TF_VAR_billing_account}

# Create the Terraform service account
## Create the service account in the Terraform admin project and download the JSON credentials:
gcloud iam service-accounts create terraform \
  --display-name "Terraform admin account"

gcloud iam service-accounts keys create ${TF_CREDS} \
  --iam-account terraform@${TF_ADMIN}.iam.gserviceaccount.com

## Grant the service account permission to view the Admin Project and manage Cloud Storage:
gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/viewer

gcloud projects add-iam-policy-binding ${TF_ADMIN} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/storage.admin



## Any actions that Terraform performs require that the API be enabled to do so.
## In this project, Terraform requires the following:
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable cloudbilling.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable serviceusage.googleapis.com
gcloud services enable container.googleapis.com

# Add organization/folder-level permissions
## Grant the service account permission to create projects and assign billing accounts:
gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectCreator

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/billing.user

gcloud organizations add-iam-policy-binding ${TF_VAR_org_id} \
  --member serviceAccount:terraform@${TF_ADMIN}.iam.gserviceaccount.com \
  --role roles/compute.xpnAdmin


# Set up remote state in Cloud Storage
## Create the remote backend bucket in Cloud Storage
gsutil mb -p ${TF_ADMIN} gs://${TF_ADMIN}

## Enable versioning for the remote bucket:
gsutil versioning set on gs://${TF_ADMIN}

## Create the backend.tf file for storage of the terraform.tfstate file:
cat >backend.tf <<EOF
terraform {
 backend "gcs" {
   bucket  = "${TF_ADMIN}"
   prefix  = "terraform/state"
 }
}
EOF

## Configure your environment for the Google Cloud Terraform provider:
export GOOGLE_APPLICATION_CREDENTIALS=${TF_CREDS}
export GOOGLE_PROJECT=${TF_ADMIN}



# NOT SURE WHAT TO DO HERE
gcloud auth activate-service-account \
  --key-file=${TF_CREDS}

# Activate current cluster with gcloud
# Alternatively do this: https://www.terraform.io/docs/providers/google/guides/using_gke_with_terraform.html
gcloud container clusters get-credentials quantum-cluster --project quantum-test-project-0a8f --zone us-east4
