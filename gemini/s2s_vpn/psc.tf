# PSC IP Address 
resource "google_compute_global_address" "googleapis_psc_ip" {
  name         = "googleapis-psc-ip"
  address_type = "INTERNAL"
  purpose      = "PRIVATE_SERVICE_CONNECT"
  network      = google_compute_network.hub_vpc.self_link
  address      = var.googleapis_psc_ip
}

resource "google_compute_global_forwarding_rule" "googleapis_psc_rule" {
  name                  = "googapiendpt"
  load_balancing_scheme = ""
  network               = google_compute_network.hub_vpc.self_link
  ip_address            = google_compute_global_address.googleapis_psc_ip.id
  target                = "all-apis"
}