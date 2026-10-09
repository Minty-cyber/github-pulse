variable "project_id" {
  description = "GCP Project ID for github-pulse"
  type = string
}

variable "region" {
  description = "Default region for resources"
  default = "us-central1"
}

variable "bq_location" {
  description = "BigQuery dataset location. Must be 'US' because the githubarchive public dataset is US-based."
  type        = string
  default     = "US"
  validation {
    condition     = var.bq_location == "US"
    error_message = "bq_location must be 'US' — the githubarchive public dataset is US-based and cross-region queries are not supported."
  }
}

variable "billing_account_id" {
  description = "Billing account ID (format: XXXXXX-XXXXXX-XXXXXX). Find via `gcloud billing accounts list`."
  type        = string
}

variable "alert_email" {
  description = "Email to receive budget alerts."
  type        = string
}

variable "budget_amount_usd" {
  description = "Monthly budget ceiling in USD. Alerts fire at 50/90/100% of this."
  type        = number
  default     = 10
}

variable "developer_email" {
  description = "Your personal Google account email — gets owner-level access to the datasets."
  type        = string
}

variable "dbt_user_bytes_per_day_gb" {
  description = "Hard cap on bytes scanned per user per day. Backstop against runaway queries."
  type        = number
  default     = 100
}

variable "labels" {
  description = "Labels applied to all resources that support them."
  type        = map(string)
  default = {
    project     = "gh-pulse"
    managed_by  = "terraform"
    environment = "prod"
  }
}