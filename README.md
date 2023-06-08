# Creating BigQuery External Tables from Google Sheets with Terraform and Cloud Build

This repo was built in support of this [blog post](). The blog itself focuses specifically on the details of creating an external table in Google BigQuery from an external Google Sheet using Terraform/Terragrunt and Cloud Build. This repo serves as a means for readers to validate the work and see the full infrastructure required to successfully deploy the solution.

To build this solution yourselves in Google Cloud, follow the steps in your own Google Cloud project (with billing enabled) - they can be achieved via the console or `gcloud` CLI tool:

1. Enable the Cloud Build API. We can't build anything from this repo without the API enabled.
2. Create a service account. During creation, grant the 'BigQuery Admin' role to the service account.
3. Add the created service account as (at least) a viewer on the Google Sheet you wish to access.
4. Grant the following roles on the Google-managed Cloud Build service account: Service Usage Admin (to enable APIs), Service Account Admin (to set an IAM binding for impersonation).
5. Create a fork of this repo. Create a trigger in Cloud Build that links to your fork and rebuilds on a push.
6. Edit `./config/project.yaml` with the values for your project: `project_id`, `region`, `service_account_id` (of the account created in step 2) and `sheets_uri` (the uri of the Google Sheet you want build your table from).
7. Push your changes to your remote fork to trigger the build.

For more context as to what these steps achieve, or why they are required, please read the blog and/or reach out to the author.
