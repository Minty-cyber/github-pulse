# ─────────────────────────────────────────────────────────────
# Four datasets, one per layer. Keeping them separate makes it
# trivial to grant different access per layer, and prevents a
# `--full-refresh` from accidentally nuking the expensive staging
# layer when you meant to rebuild marts.
# ─────────────────────────────────────────────────────────────

locals {
  datasets = {
    raw_source_refs = {
      description = "Empty dataset — exists only to hold external table definitions / source references. The real raw data lives in bigquery-public-data.githubarchive and is never copied here."
    }
    dbt_staging = {
      description = "Pre-aggregated staging tables built by dbt. Expensive to rebuild (scans GH Archive raw), so protect this one."
    }
    dbt_marts = {
      description = "Final mart tables that power the Year-in-Review dashboard. Cheap to rebuild from staging."
    }
    dbt_dev = {
      description = "Developer scratch dataset. Safe to blow away with --full-refresh."
    }
  }
}

resource "google_bigquery_dataset" "datasets" {
  for_each = local.datasets

  project       = var.project_id
  dataset_id    = each.key
  friendly_name = each.key
  description   = each.value.description
  location      = var.location
  labels        = var.labels

  access {
    role          = "OWNER"
    user_by_email = var.developer_email
  }

  access {
    role          = "OWNER"
    special_group = "projectOwners"
  }
  access {
    role          = "WRITER"
    special_group = "projectWriters"
  }
  access {
    role          = "READER"
    special_group = "projectReaders"
  }
}