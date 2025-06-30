resource "google_dns_policy" "hub_inbound_policy" {
  name                      = var.dns_policy_name
  enable_inbound_forwarding = true
  enable_logging            = true
  networks {
    network_url = google_compute_network.hub_vpc.self_link
  }
}

resource "google_dns_managed_zone" "googleapis" {
  name        = "googleapis-zone"
  dns_name    = "googleapis.com."
  description = "Google API DNS Zone"
  labels = {
    "zone-type" = "private"
  }
  visibility = "private"
  private_visibility_config {
    networks {
      network_url = google_compute_network.hub_vpc.self_link
    }
  }
}

resource "google_dns_record_set" "googleapis" {
  name         = "googleapis.com."
  type         = "A"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas      = [google_compute_global_address.googleapis_psc_ip.address]
}

resource "google_dns_record_set" "wildcard_googleapis" {
  name         = "*.googleapis.com."
  type         = "CNAME"
  ttl          = 300
  managed_zone = google_dns_managed_zone.googleapis.name
  rrdatas      = ["googleapis.com."]
}