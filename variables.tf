
# The ID of your Google Cloud project (e.g., 'my-project-123').
variable "project_id" {
  description = "The ID of the GCP project to protect with the VPC Service Controls perimeter."
  type        = string
}

# The numerical ID of your Google Cloud project (e.g., '123456789012').
# This is different from the project ID and is used in the 'members' field.
variable "gcp_project_number" {
  description = "The numerical ID of the GCP project to protect."
  type        = string
}

# The Access Policy number under which the service perimeter will be created.
# This policy is typically created at the organization level.
# You can find this by running `gcloud access-context-manager policies list`.
variable "access_policy_number" {
  description = "The numerical ID of the Access Policy under which the perimeter will be created."
  type        = string
}

