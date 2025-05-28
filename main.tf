
data "google_access_context_manager_access_policy" "access-policy" {
  parent = "organizations/771068502405"
  # title  = "Vertex API VPC-SC"
}


resource "google_access_context_manager_service_perimeter" "granular-controls-perimeter" {
  parent         = "accessPolicies/${data.google_access_context_manager_access_policy.access-policy.name}"
  name           = "accessPolicies/${data.google_access_context_manager_access_policy.access-policy.name}/servicePerimeters/Gemini"
  title          = "Gemini-vpc-sc-perimeter"
  perimeter_type = "PERIMETER_TYPE_REGULAR"
  lifecycle {
    ignore_changes = [status[0].ingress_policies, status[0].resources] # Allows ingress policies to be managed by google_access_context_manager_service_perimeter_ingress_policy resources
  }
  status {
    restricted_services = ["aiplatform.googleapis.com", "storage.googleapis.com"]
    #resources = ["projects/${var.gcp_project_number}"]

  }

}



resource "google_access_context_manager_service_perimeter_resource" "service-perimeter-resource" {
  perimeter_name = google_access_context_manager_service_perimeter.granular-controls-perimeter.name
  resource       = "projects/${var.gcp_project_number}"
}

# Ingress Rule to allow IPs

resource "google_access_context_manager_service_perimeter_ingress_policy" "ingress_policy" {
  perimeter = google_access_context_manager_service_perimeter.granular-controls-perimeter.name
  title     = "Gemini_Inbound"
  ingress_from {
    identity_type = "ANY_IDENTITY"
    sources {
      access_level = google_access_context_manager_access_level.access-level.name
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

resource "google_access_context_manager_access_level" "access-level" {
  parent = "accessPolicies/${data.google_access_context_manager_access_policy.access-policy.name}"
  name   = "accessPolicies/${data.google_access_context_manager_access_policy.access-policy.name}/accessLevels/us_only"
  title  = "us_only"
  basic {
    conditions {

      regions = [
        "US",
      ]
    }
  }
}

