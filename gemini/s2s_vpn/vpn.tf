# Google VPN GW and external (AWS/on-premise) GW
resource "google_compute_ha_vpn_gateway" "hub_gateway" {
  name    = var.ha_vpn_gw_name
  region  = var.region
  network = google_compute_network.hub_vpc.self_link
}

resource "google_compute_external_vpn_gateway" "external_gateway" {
  name            = var.external_gw_name
  redundancy_type = "SINGLE_IP_INTERNALLY_REDUNDANT"
  description     = "external gw"
  interface {
    id         = 0
    ip_address = var.external_gw_ip
  }
}

resource "google_compute_vpn_tunnel" "tunnel0" {
  name                            = "ha-vpn-tunnel0"
  region                          = var.region
  vpn_gateway                     = google_compute_ha_vpn_gateway.hub_gateway.id
  peer_external_gateway           = google_compute_external_vpn_gateway.external_gateway.id
  peer_external_gateway_interface = 0
  shared_secret                   = var.shared_secret
  router                          = google_compute_router.hub_router.id
  vpn_gateway_interface           = 0
}

resource "google_compute_router_interface" "hub_interface0" {
  name       = "hubrouter-interfance1"
  router     = google_compute_router.hub_router.name
  region     = var.region
  ip_range   = "169.254.130.149/30"
  vpn_tunnel = google_compute_vpn_tunnel.tunnel0.name
}

resource "google_compute_router_peer" "hub_peer0" {
  name                      = "hub-peer0"
  router                    = google_compute_router.hub_router.name
  region                    = var.region
  peer_ip_address           = "169.254.130.150"
  peer_asn                  = var.peer_asn
  advertised_route_priority = 100
  interface                 = google_compute_router_interface.hub_interface0.name
}
