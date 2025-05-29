variable "project_id" {
  description = "The ID of the GCP project to protect with the VPC Service Controls perimeter."
  type        = string
}

variable "gcp_project_number" {
  description = "The numerical ID of the GCP project to protect."
  type        = string
}

variable "organization_id" {
  description = "GCP Organization ID"
  type        = string
}

variable "vpc_sc_perimeter_name" {
  description = "VPC SC perimeter name"
  type        = string
}

variable "restricted_ips" {
  description = "List of Restricted IP ranges"
  type        = list(string)
}

variable "org_access_policy" {
  description = "Org policy number"
  type        = string
  default     = ""
}

variable "services_to_enable" {
  type = list(string)
  default =  [
    
    "aiplatform.googleapis.com",
    "accesscontextmanager.googleapis.com",
    "storage.googleapis.com"
  ]
}