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
- Building this project from scratch with 'raw' Terraform will return an error relating to IAM permissions when trying to generate the access token. This occurs because IAM is only *eventually consistent*, and as such, the binding won't have fully propagated in the time bewteen setting the binding and trying to generate the access token. 
- The Google provider for Terraform has retries and timeouts built into provisioning resources, but not data sources. Hashicorp specify in their [docs](https://developer.hashicorp.com/terraform/plugin/sdkv2/resources/retries-and-customizable-timeouts) that implementing this functionality is the responsibility of the providers. The issue has been raised for both the [AWS](https://github.com/hashicorp/terraform-provider-aws/issues/11342) and [Google](https://github.com/hashicorp/terraform-provider-google/issues/1131) providers, and has since been implemented for [AWS](https://github.com/hashicorp/terraform-provider-aws/blob/v4.25.0/CHANGELOG.md), but not for [Google]().
- The workaround for this is (quite literally) waiting for the binding to fully propagate, which [Google note](https://cloud.google.com/iam/docs/access-change-propagation) usually takes 2 minutes, but can take sufficiently longer. A simple solution is a `time_sleep' resource to create a 2 minute delay, but this will often make builds take longer than necessary, and may sometimes not been adequate.
- An alternative is to implement the retry/timeout functionality within the build configuration. Whilst this is entirely doable from scratch, Terragrunt has this functionality baked in so we chose to use it. Additionally, this also allowed for the generation of dynamic provider blocks, making the code more easily shareable, with configuration taking place entirely in a single `project.yaml` file.
