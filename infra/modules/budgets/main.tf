data "google_project" "this" {
  project_id = var.project_id
}

resource "google_monitoring_notification_channel" "email" {
  project      = var.project_id
  display_name = "gh-pulse budget alerts"
  type         = "email"
  labels = {
    email_address = var.alert_email
  }
}

resource "google_billing_budget" "project_budget" {
  billing_account = var.billing_account_id
  display_name    = "gh-pulse monthly budget"

  budget_filter {
    projects = ["projects/${data.google_project.this.number}"]
  }

  amount {
    specified_amount {
      currency_code = "USD"
      units         = tostring(var.budget_amount_usd)
    }
  }

  threshold_rules {
    threshold_percent = 0.5
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 0.9
    spend_basis       = "CURRENT_SPEND"
  }
  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "CURRENT_SPEND"
  }

  threshold_rules {
    threshold_percent = 1.0
    spend_basis       = "FORECASTED_SPEND"
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.email.id,
    ]
    disable_default_iam_recipients = false
  }
}