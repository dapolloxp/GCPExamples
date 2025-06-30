variable "project_id" {
  description = "The ID of the GCP project to protect with the VPC Service Controls perimeter."
  type        = string
}

variable "gcp_project_number" {
  description = "The numerical ID of the GCP project to protect."
  type        = string
}

variable "services_to_enable" {
  type = list(string)
  default = [
    "aiplatform.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com"
  ]
}

variable "region" {
  type    = string
  default = "us-central1"
}

variable "vpc_name" {
  type    = string
  default = "hub-vpc"
}

variable "vpc_mtu" {
  type    = number
  default = 1460
}

variable "hub_router_name" {
  type    = string
  default = "hub-router"
}

variable "hub_asn" {
  type    = number
  default = 65001
}

variable "dns_policy_name" {
  type    = string
  default = "hub-inbound-policy"
}

variable "googleapis_psc_ip" {
  type    = string
  default = "10.100.100.100"
}

variable "ha_vpn_gw_name" {
  type    = string
  default = "hub-vpn-gw"
}

variable "external_gw_name" {
  type    = string
  default = "external-vpn-gw"
}

variable "external_gw_ip" {
  type    = string
  default = "172.0.0.1"
}

variable "shared_secret" {
  type    = string
  default = "Some Secret Message"
}

variable "peer_asn" {
  type    = number
  default = 65002
}