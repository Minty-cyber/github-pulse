output "dataset_ids" {
  description = "List of dataset IDs created."
  value       = [for d in google_bigquery_dataset.datasets : d.dataset_id]
}

output "dataset_self_links" {
  description = "Self-links for the created datasets."
  value       = { for k, d in google_bigquery_dataset.datasets : k => d.self_link }
}