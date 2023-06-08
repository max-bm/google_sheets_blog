retryable_errors = [
    "(?s).*Error.*iam.serviceAccounts.getAccessToken.*data.google_service_account_access_token.gdrive.*"
]
retry_max_attempts = 12
retry_sleep_interval_sec = 10

remote_state {
    backend = "gcs"
    generate = {
        path = "backend.tf"
        if_exists = "overwrite"
    }
    config = {
        bucket = "${local.project_config.project_id}-tfstate"
        prefix = "terraform/blog"
    }
}
