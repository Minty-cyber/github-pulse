variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "location" {
  description = "BigQuery dataset location"
  type = string
}

variable "developer_email" {
  description = "Developers Google account email to grant OWNER on each dataset"
  type = string
}

variable "labels" {
  description = "Labels applied to each dataset."
  type        = map(string)
  default     = {}
}