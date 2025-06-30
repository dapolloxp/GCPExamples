# Enable Relevant APIs
resource "google_project_service" "enable-services" {
  for_each           = toset(var.services_to_enable)
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

# Create Hub VPC and cloud router 
resource "google_compute_network" "hub_vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  mtu                     = var.vpc_mtu
}

resource "google_compute_router" "hub_router" {
  name    = var.hub_router_name
  region  = var.region
  network = google_compute_network.hub_vpc.self_link
  bgp {
    asn               = var.hub_asn
    advertise_mode    = "CUSTOM"
    advertised_groups = ["ALL_SUBNETS"]
    advertised_ip_ranges {
      range = "35.199.192.0/19"
    }
    advertised_ip_ranges {
      range = "${var.googleapis_psc_ip}/32"
    }
  }
}