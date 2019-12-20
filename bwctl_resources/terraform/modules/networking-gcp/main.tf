resource "google_compute_network" "network" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}"
  auto_create_subnetworks = "false"
}

resource "google_compute_subnetwork" "orchestrator_subnet" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-orchestrator-subnet"
  region = "${var.region}"
  network = "${google_compute_network.network.self_link}"
  ip_cidr_range = "${var.orchestrator_subnet_cidr}"
}

resource "google_compute_subnetwork" "workload_subnet" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-workload-subnet"
  region = "${var.region}"
  network = "${google_compute_network.network.self_link}"
  ip_cidr_range = "${var.workload_subnet_cidr}"
}

resource "google_compute_subnetwork" "processor_subnet" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-processor-subnet"
  region = "${var.region}"
  network = "${google_compute_network.network.self_link}"
  ip_cidr_range = "${var.processor_subnet_cidr}"
}
