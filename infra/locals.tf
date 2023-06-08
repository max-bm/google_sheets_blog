locals {
  apis = toset([
    "bigquery.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  project_config  = yamldecode(file("./config/project.yaml"))
  bigquery_config = yamldecode(file("./config/bigquery.yaml"))
  datasets = {
    for ds in local.bigquery_config.bigquery.datasets : ds.name => ds
  }
  tables = {
    for tbl in flatten([
      for _, ds in local.datasets : [
        for tbl_inner in ds.tables : merge(tbl_inner, { dataset_id = ds.name })
      ]
    ]) : "${tbl.dataset_id}-${tbl.name}" => tbl
  }
}
