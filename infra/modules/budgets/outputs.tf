output "budget_name" {
  description = "Full resource name of the created budget."
  value       = google_billing_budget.project_budget.name
}

output "notification_channel_id" {
  description = "ID of the email notification channel."
  value       = google_monitoring_notification_channel.email.id
}