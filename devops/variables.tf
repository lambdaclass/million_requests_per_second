variable "organization" {}
variable "token" {}
variable "region" {
  default = "par1"
}

variable "ssh_key" {}

// Number of clients to create
variable "count" {
  default = 1
}

output "server_ip" {
  value = "${scaleway_ip.server_ip.ip}"
}

output "client_ips" {
  value = "${formatlist("%v", scaleway_ip.client_ips.*.ip)}"
}
