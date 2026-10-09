variable "project_id" {
  description = "GCP project ID the budget scopes to."
  type        = string
}

variable "billing_account_id" {
  description = "Billing account ID (format: XXXXXX-XXXXXX-XXXXXX)."
  type        = string
}

variable "alert_email" {
  description = "Email to receive budget threshold notifications."
  type        = string
}

variable "budget_amount_usd" {
  description = "Monthly budget ceiling in USD."
  type        = number
}