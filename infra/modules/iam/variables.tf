variable "project_id" {
  description = "GCP Project ID"
  type = string
}

variable "dataset_ids" {
  description = "Dataset IDs the service accounts needs access to"
  type = list(string)
}

variable "write_key_to" {
  description = "Local filesystem path where the service account key will be written. Must be gitignored."
  type        = string
}