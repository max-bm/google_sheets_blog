locals {

  apis = [
    "bigquery.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
  default_labels = {
    "department" : "medium"
  }
  project_config     = yamldecode(file("${var.schema_file_path}/project.yaml"))
  bigquery           = yamldecode(file("${var.schema_file_path}/bigquery.yaml"))
  datasets_to_create = { for ds in local.bigquery.bigquery.datasets : ds.name => ds if try(ds.create, true) }
  tables = flatten([for dataset in local.bigquery.bigquery.datasets : [
    for tbl, val in dataset.tables : merge(val, { dataset_id = dataset.name })
  ]])
}
