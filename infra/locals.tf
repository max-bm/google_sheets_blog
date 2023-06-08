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
        for tbl_inner in ds.tables : merge(
          tbl_inner,
          { dataset_id = ds.name },
          { external_data_configuration = merge([
            tbl_inner.external_data_configuration,
            { sheets_uris = local.project_config.sheets_uri }
          ]) }
        )
      ]
    ]) : "${tbl.dataset_id}-${tbl.name}" => tbl
  }
}
