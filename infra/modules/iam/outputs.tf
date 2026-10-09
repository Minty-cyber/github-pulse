output "service_account_email" {
  description = "Email of the dbt service account."
  value       = google_service_account.dbt.email
}

output "service_account_name" {
  description = "Fully qualified name of the dbt service account."
  value       = google_service_account.dbt.name
}

output "service_account_key_path" {
  description = "Local path to the generated service account key."
  value       = local_sensitive_file.dbt_key.filename
}