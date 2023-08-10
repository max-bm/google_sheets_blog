#!/bin/bash
# ---
# This script is to be run once in a new Google Cloud project - it performs the setup
# required to successfully deploy an external table from a Google Sheets source, via
# Terraform and Cloud Build. The steps are outlined below, but in summary:
#   1. Read project-specific variables from config.env
#   2. Enable the Cloud Build API and configure its service account
#   3. Create a storage bucket for Cloud Build and Terraform
#   4. Create and configure the service account with access to Google Sheets
#   5. Generate a config.tf file so that the GCS backend can be configured dynamically
#
# These steps cannot be included within the cloudbuild.yaml steps as they are either
# prerequisites to using Cloud Build, or they would alter permissions that must be set
# prior to the instantiation of a Cloud Build instance.
#
# The config.tf file is generated dynamically as the GCS backend attributes cannot be
# variable. By writing to the file from within this script, the bucket name can be
# inferred from the PROJECT_ID, set within the config.env file.
# ---

# --- SETUP ---
source config.env
gcloud config set project $PROJECT_ID
CLOUD_BUILD_SERVICE_ACCOUNT=$(gcloud projects describe $PROJECT_ID \
    --format="value(projectNumber)")

# --- CLOUD BUILD PREREQUISITES ---
# Enable Cloud Build API and add permissions to Cloud Build service account
gcloud services enable cloudbuild.googleapis.com
gcloud services enable iam.googleapis.com
# Role to set project-level IAM binding
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CLOUD_BUILD_SERVICE_ACCOUNT@cloudbuild.gserviceaccount.com \
    --role='roles/resourcemanager.projectIamAdmin'
# Role to set service account IAM bindings
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CLOUD_BUILD_SERVICE_ACCOUNT@cloudbuild.gserviceaccount.com \
    --role='roles/iam.serviceAccountAdmin'
# Allow service account to enable APIs
gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member=serviceAccount:$CLOUD_BUILD_SERVICE_ACCOUNT@cloudbuild.gserviceaccount.com \
    --role='roles/serviceusage.serviceUsageAdmin'
# Create bucket for Cloud Build and Terraform
gcloud storage buckets create gs://"$PROJECT_ID"_cloudbuild \
    --location=$REGION

# --- SERVICE ACCOUNT CONFIGURATION ---
# Create service account to impersonate and add BigQuery admin role
gcloud iam service-accounts create $SHEETS_ACCESS_SERVICE_ACCOUNT \
    --description="" \
    --display-name="Google Sheets Access service account"

# --- CONFIGURE TERRAFORM BACKEND ---
# Configure required providers and GCS for backend
# Generate it dynamically so it can read values from config
BUCKET="$PROJECT_ID"_cloudbuild
cat <<EOF >infra/config.tf
terraform {
    required_providers {
        google = {
            source  = "hashicorp/google"
            version = "4.76.0"
        }
    }
    backend "gcs" {
        bucket = "$BUCKET"
        prefix = "terraform/state"
    }
}
EOF
