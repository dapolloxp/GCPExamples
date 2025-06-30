data "google_project" "project" {}
data "google_client_config" "current" {}

provider "google" {
  project               = var.project_id
  billing_project       = var.project_id
  user_project_override = true
}