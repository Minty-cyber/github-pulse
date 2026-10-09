terraform {
    required_version = ">=1.6.0"
  backend "gcs" {
    # bucket must be created before terraform init is ran
    prefix = "gh-pulse/state"
  }
}