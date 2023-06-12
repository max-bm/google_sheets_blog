# Creating BigQuery External Tables from Google Sheets with Terraform and Cloud Build

This repo was built in support of this [blog post](). The blog itself focuses specifically on the details of creating an external table in Google BigQuery from a Google Sheet using Terraform/Terragrunt and Cloud Build. This repo serves as a means for readers to validate the work and see the full infrastructure required to successfully deploy the solution.

To build this solution yourselves in Google Cloud, follow the steps in your own Google Cloud project (with billing enabled) - they can be achieved via the console or `gcloud` CLI tool:

1. Enable the Cloud Build API. We can't build anything from this repo without the API enabled.
2. Grant the following roles on the Google-managed Cloud Build service account: Service Usage Admin (to enable APIs), Service Account Admin (to set an IAM binding for impersonation).
3. Create a service account. During creation, grant the 'BigQuery Admin' role to the service account.
4. If the Google Sheet you want to access is restricted, add the created service account as (at least) a viewer.
5. In Cloud Shell: clone this repository and go into it, make changes in `./infra/config/project.yaml` to reflect your project, and submit a build to Cloud Build from the root of the repo with `gcloud builds submit .`

For full context as to what these steps achieve, or why they are required, please read the blog and/or reach out to the author.

## Interesting Bits

