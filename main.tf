provider "scaleway" {
  organization = "${var.organization}"
  token        = "${var.token}"
  region       = "${var.region}"
}

resource "scaleway_ssh_key" "ssh_key" {
    key = "${var.ssh_key}"
}

resource "scaleway_ip" "server_ip" {
  server = "${scaleway_server.server.id}"
}

resource "scaleway_ip" "client_ips" {
  count = "${var.count}"
  server = "${element(scaleway_server.clients.*.id, count.index)}"
}

resource "scaleway_server" "server" {
  name  = "load-server"
  image = "31dfef82-9b45-4b01-9656-031617f36599" // Debian Stretch
  type  = "C1"
  depends_on = ["scaleway_ssh_key.ssh_key"]

  provisioner "file" {
    source      = "install_script.sh"
    destination = "/tmp/install_script.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_script.sh",
      "/tmp/install_script.sh",
      "/million_requests_per_second/make server"
    ]
  }
}

resource "scaleway_server" "clients" {
  count = "${var.count}"
  name  = "load-client-${count.index}"
  image = "31dfef82-9b45-4b01-9656-031617f36599"
  type  = "C1"
  depends_on = ["scaleway_server.server"]

  provisioner "remote-exec" {
    script = "./install_script.sh"
  }
}
