data "google_compute_image" "image" {
  family = "${var.image}"
  project = "${var.project}"
}

resource "google_compute_address" "ip" {
  count = "${var.instance_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-ip"
}

resource "google_compute_instance" "vm" {
  count = "${var.instance_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}"
  machine_type = "${var.instance_type}"
  zone = "${var.zone}"
  can_ip_forward = true
  tags = "${var.firewall_tags}"
  boot_disk {
    auto_delete = true
    initialize_params {
      size = "${var.disk_size}"
      image = "${data.google_compute_image.image.self_link}"
    }
  }
  metadata {
    hostname = "${var.prefix}${var.suffix}"
    sshKeys = "${var.ssh_user}:${file(var.ssh_pub_key_file)}"
  }
  network_interface {
    subnetwork = "${var.subnet}"
    access_config {
      nat_ip = "${element(google_compute_address.ip.*.address, count.index)}"
    }
  }
  lifecycle {
    ignore_changes = ["boot_disk"]
  }
}
