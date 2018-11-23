variable "organization" {}
variable "token" {}
variable "region" {
  default = "par1"
}

// Number of clients to create
variable "count" {
  default = 1
}

output "server_ip" {
  value = "${scaleway_server.server.public_ip}"
}

output "client_ips" {
  value = "value"
}
