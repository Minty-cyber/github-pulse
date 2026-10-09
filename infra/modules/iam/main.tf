# service account dbt uses to run queries.

resource "google_service_account" "dbt" {
  project = var.project_id
  account_id = "dbt-runner"
  display_name = "dbt-runner"
  description = "Service Account dbt uses to run queries against BigQuery"
}

resource "google_project_iam_member" "dbt_data_editor" {
    project = var.project_id
    role = "roles/bigquery.dataEditor"
    member = "serviceAccount:${google_service_account.dbt.email}"

}


resource "google_project_iam_member" "dbt_job_user" {
    project = var.project_id
    role = "roles/bigquery.jobUser"
    member = "serviceAccount:${google_service_account.dbt.email}"
}

resource "google_project_iam_member" "dbt_data_viewer" {
    project = var.project_id
    role = "roles/bigquery.dataViewer"
    member = "serviceAccount:${google_service_account.dbt.email}"
}