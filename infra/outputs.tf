output "project_id" {
  description = "GCP project ID."
  value       = var.project_id
}

output "dataset_ids" {
  description = "The BigQuery dataset IDs created for the project."
  value       = module.bigquery.dataset_ids
}

output "dbt_service_account_email" {
  description = "Service account dbt uses to run queries."
  value       = module.iam.service_account_email
}

output "dbt_service_account_key_path" {
  description = "Local path to the dbt service account key file. Reference this from profiles.yml."
  value       = module.iam.service_account_key_path
  sensitive   = true
}

output "profiles_yml_snippet" {
  description = "Paste this into dbt/profiles.yml to connect dbt to BigQuery."
  value       = <<-EOT
    gh_pulse:
      target: dev
      outputs:
        dev:
          type: bigquery
          method: service-account
          project: ${var.project_id}
          dataset: dbt_dev
          location: ${var.bq_location}
          threads: 4
          keyfile: ${module.iam.service_account_key_path}
          priority: interactive
          maximum_bytes_billed: 50000000000 # 50 GB — reject runaway queries
  EOT
}