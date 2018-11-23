provider "scaleway" {
  organization = "${var.organization}"
  token        = "${var.token}"
  region       = "${var.region}"
}

resource "scaleway_server" "server" {
  name  = "load-server"
  image = "40bbd507-0223-4334-91ba-3885b7a7e61c"
  type  = "C1"
}

resource "scaleway_server" "clients" {
  count = "${var.count}"
  name  = "load-client-${count.index}"
  image = "40bbd507-0223-4334-91ba-3885b7a7e61c"
  type  = "C1"
  depends_on = ["scaleway_server.server"]

  provisioner "local-exec" {
    command = "export SERVER=${scaleway_server.server.public_ip}"
  }
}
