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
  count   = "${var.count}"
  server  = "${element(scaleway_server.clients.*.id, count.index)}"
}

resource "scaleway_ip" "monitor_ip" {
  server = "${scaleway_server.monitor.id}"
}

resource "scaleway_server" "server" {
  name        = "load-server"
  image       = "31dfef82-9b45-4b01-9656-031617f36599" // Debian Stretch
  type        = "C1"
  depends_on  = ["scaleway_ssh_key.ssh_key"]
}

resource "scaleway_server" "clients" {
  count       = "${var.count}"
  name        = "load-client-${count.index}"
  image       = "31dfef82-9b45-4b01-9656-031617f36599"
  type        = "C1"
  depends_on  = ["scaleway_server.server"]
}

resource "scaleway_server" "monitor" {
  name        = "load-monitor"
  image       = "31dfef82-9b45-4b01-9656-031617f36599" // Debian Stretch
  type        = "C1"
  depends_on  = ["scaleway_server.clients"]
}

data "template_file" "ansible_inventory_tpl" {
  template = "${file("devops/inventory.tpl")}"

  vars {
    server_ip   = "${scaleway_ip.server_ip.ip}"
    client_ips  = "${join("\n", scaleway_ip.client_ips.*.ip)}"
    monitor_ip  = "${scaleway_ip.monitor_ip.ip}"
  }
}

resource "local_file" "ansible_inventory" {
  content   = "${data.template_file.ansible_inventory_tpl.rendered}"
  filename  = "inventory"
}
