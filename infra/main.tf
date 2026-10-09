locals {
   required_apis = [
    "bigquery.googleapis.com",
    "billingbudgets.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
  ]
}

resource "google_project_service" "apis" {
  for_each                   = toset(local.required_apis)
  project                    = var.project_id
  service                    = each.value
  disable_dependent_services = false
  disable_on_destroy         = false
}

module "bigquery" {
  source = "./modules/bigquery"

  project_id      = var.project_id
  location        = var.bq_location
  developer_email = var.developer_email
  labels          = var.labels

  depends_on = [google_project_service.apis]
}

module "iam" {
  source = "./modules/iam"

  project_id   = var.project_id
  dataset_ids  = module.bigquery.dataset_ids
  write_key_to = "${path.module}/.secrets/dbt-service-account.json"

  depends_on = [google_project_service.apis]
}

module "budgets" {
  source = "./modules/budgets"

  project_id         = var.project_id
  billing_account_id = var.billing_account_id
  alert_email        = var.alert_email
  budget_amount_usd  = var.budget_amount_usd

  depends_on = [google_project_service.apis]
}
