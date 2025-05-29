# Enable VPC-SC, Vertex and GCS APIs 
resource "google_project_service" "vpc_sc" {
  project = var.project_id
  service = "accesscontextmanager.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

resource "google_project_service" "vertex" {
  project = var.project_id
  service = "aiplatform.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}


resource "google_project_service" "gcs" {
  project = var.project_id
  service = "storage.googleapis.com"
  timeouts {
    create = "30m"
    update = "40m"
  }
  disable_on_destroy = false
}

# Create organization level access policy 
resource "google_access_context_manager_access_policy" "org_access_policy" {
  parent     = "organizations/${var.organization_id}"
  title      = "Org Access Policy"
  depends_on = [google_project_service.vpc_sc]
}

resource "google_access_context_manager_service_perimeter" "gemini_perimeter" {
  parent         = "accessPolicies/${google_access_context_manager_access_policy.org_access_policy.name}"
  name           = "accessPolicies/${google_access_context_manager_access_policy.org_access_policy.name}/servicePerimeters/${var.vpc_sc_perimeter_name}"
  title          = var.vpc_sc_perimeter_name
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  lifecycle {
    ignore_changes = [status[0].ingress_policies, status[0].resources] # Allows ingress policies to be managed by google_access_context_manager_service_perimeter_ingress_policy resources
  }
  status {
    restricted_services = ["aiplatform.googleapis.com", "storage.googleapis.com"]
  }
}

resource "google_access_context_manager_service_perimeter_resource" "service_perimeter_resource" {
  perimeter_name = google_access_context_manager_service_perimeter.gemini_perimeter.name
  resource       = "projects/${var.gcp_project_number}"
}

# Ingress Rule to allow IPs
resource "google_access_context_manager_service_perimeter_ingress_policy" "ingress_policy" {
  perimeter = google_access_context_manager_service_perimeter.gemini_perimeter.name
  title     = "Gemini_Inbound"
  ingress_from {
    identity_type = "ANY_IDENTITY"
    sources {
      access_level = google_access_context_manager_access_level.us_access_level.name
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
  lifecycle {
    create_before_destroy = true
  }
}

resource "google_access_context_manager_access_level" "us_access_level" {
  parent = "accessPolicies/${google_access_context_manager_access_policy.org_access_policy.name}"
  name   = "accessPolicies/${google_access_context_manager_access_policy.org_access_policy.name}/accessLevels/us_only"
  title  = "us_only"
  basic {
    conditions {
      regions = [
        "US",
      ]
    }
  }
}