# Enable VPC-SC, Vertex and GCS APIs

locals {
  org_access_policy_name = var.org_access_policy != "" ? var.org_access_policy : google_access_context_manager_access_policy.org_access_policy[0].name
}

resource "google_project_service" "enable-services" {
  for_each           = toset(var.services_to_enable)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Create organization level access policy
resource "google_access_context_manager_access_policy" "org_access_policy" {
  count      = var.org_access_policy != "" ? 0 : 1
  parent     = "organizations/${var.organization_id}"
  title      = "Org Access Policy"
  depends_on = [google_project_service.enable-services]
}

# Define VPC SC perimeter associated with access policy
resource "google_access_context_manager_service_perimeter" "gemini_perimeter" {
  parent         = "accessPolicies/${local.org_access_policy_name}"
  title = "${var.vpc_sc_perimeter_name}"
  name           = "accessPolicies/${local.org_access_policy_name}/servicePerimeters/${var.vpc_sc_perimeter_name}"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  lifecycle {
    ignore_changes = [status[0].ingress_policies, status[0].resources]
  }
  status {
    restricted_services = ["aiplatform.googleapis.com", "storage.googleapis.com"]
  }
}

# Add project to VPC SC Perimeter
resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_resource" {
  perimeter_name = google_access_context_manager_service_perimeter.gemini_perimeter.name
  resource       = "projects/${var.gcp_project_number}"
}

# Create Ingress Rule to allow Restricted IPs
resource "google_access_context_manager_service_perimeter_ingress_policy" "ingress_policy" {
  perimeter = google_access_context_manager_service_perimeter.gemini_perimeter.name
  title     = "Gemini_Inbound"
  ingress_from {
    identity_type = "ANY_IDENTITY"
    sources {
      access_level = google_access_context_manager_access_level.access_level.name
    }
  }
  ingress_to {
    resources = ["*"]
    operations {
      service_name = "aiplatform.googleapis.com"
      method_selectors {
        method = "*"
      }
    }
  }
}

resource "google_access_context_manager_access_level" "access_level" {
  name   = "accessPolicies/${local.org_access_policy_name}/accessLevels/restrictedip_only"
  parent = "accessPolicies/${local.org_access_policy_name}"
  title  = "restrictedip_only"
  basic {
    conditions {
      ip_subnetworks = var.restricted_ips
    }
  }
}
