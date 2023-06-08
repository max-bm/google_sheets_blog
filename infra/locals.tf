locals {
  apis = toset([
    "bigquery.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ])
  project_config = yamldecode(file("./config/project.yaml"))
  bigquery       = yamldecode(file("./config/bigquery.yaml"))
  datasets = {
    for ds in local.bigquery.bigquery.datasets : ds.name => ds
  }
  table_list = [
    for ds in local.datasets : {
      for tbl in ds.tables : "${ds.name}-${tbl.name}" => merge(tbl, { dataset_id = ds.name })
    }
  ]
  tables = {
    for tbl in flatten([
      for ds in local.datasets : [
        for key, val in ds.tables : merge(val, { dataset_id = ds.name})
      ]
    ]) : "${tbl.dataset_id}-${tbl.name}" => tbl
  } 
