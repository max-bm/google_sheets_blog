# Creating BigQuery External Tables from Google Sheets with Terraform and Cloud Build

This repo was built in support of this [blog post](). The blog itself focuses specifically on the details of deploying an external table with a Google Sheet as its source in BigQuery, using Terraform and Cloud Build.

To build this solution in Google Cloud, open Cloud Shell within your own Google Cloud project (with billing enabled) and follow:

1. Clone this repository:

    ```bash
    git clone https://github.com/max-bm/google_sheets_blog.git
    ```

1. Edit the `config.env` file with your project details:

    ```txt
    # Set project-specific variables
    PROJECT_ID=<Your project ID (not name)>
    REGION=<Your preferred Google-supported region for deployment>
    SHEETS_ACCESS_SERVICE_ACCOUNT=<The name of the service account to be created for access to Google Sheets>
    SHEETS_SOURCE_URI=<Full URI of Google Sheets file>
    SHEETS_RANGE=<Google Sheets range from which to pull data>
    SKIP_LEADING_ROWS=<Number of rows which correspond to the table header>
    ```

1. Run `project_setup.sh` to setup your project and service accounts, and to generate a `config.tf` to dynamically configure your Google Cloud Storage backend for Terraform. From the repository root, run:

    ```bash
    chmod u+x project_setup.sh && ./project_setup.sh
    ```

1. If the Google Sheet you want to access is not public, add the created service account

    ```txt
    <SHEETS_ACCESS_SERVICE_ACCOUNT>@<PROJECT_ID>.iam.gserviceaccount.com
    ```

    as (at least) a viewer of the file.

1. Submit the build to Cloud Build to deploy the infrastructure. From the repository root, run:

    ```bash
    gcloud builds submit .
    ```

## Interesting Bits

- The `time_sleep` resource within `infra/impersonation.tf` is necessary to avoid an error when trying to generate the service account access token. IAM is only *eventually consistent*, and as such, the binding won't have fully propagated before trying to generate the access token.
- The Google provider for Terraform has retries and timeouts built into provisioning resources, but not data sources. Hashicorp specify in their [docs](https://developer.hashicorp.com/terraform/plugin/sdkv2/resources/retries-and-customizable-timeouts) that implementing this functionality is the responsibility of the provider. The issue has been raised for both the [AWS](https://github.com/hashicorp/terraform-provider-aws/issues/11342) and [Google](https://github.com/hashicorp/terraform-provider-google/issues/1131) providers, and has since been implemented for [AWS](https://github.com/hashicorp/terraform-provider-aws/blob/v4.25.0/CHANGELOG.md), but not yet for Google.
- The workaround for this is (quite literally) waiting for the binding to fully propagate, which [Google note](https://cloud.google.com/iam/docs/access-change-propagation) usually takes 2 minutes, but can take sufficiently longer, meaning the automated deployment in this repository *could* still fail due to this error.
