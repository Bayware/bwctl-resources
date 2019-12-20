resource "google_compute_firewall" "ssh-bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-ssh-bastion"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["firewall-ssh-bastion-${var.environment}"]
  source_ranges = ["${var.bastion_ip}/32"]
}

resource "google_compute_firewall" "icmp-bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-icmp-bastion"
  network = "${var.network}"
  allow {
    protocol = "icmp"
  }
  target_tags = ["firewall-icmp-bastion-${var.environment}"]
  source_ranges = ["${var.bastion_ip}/32"]
}

resource "google_compute_firewall" "ssh-all" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-ssh-all"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["firewall-ssh-all-${var.environment}"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "icmp-all" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-icmp-all"
  network = "${var.network}"
  allow {
    protocol = "icmp"
  }
  target_tags = ["firewall-icmp-all-${var.environment}"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "wkld-internal" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-wkld-internal"
  network = "${var.network}"
  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_tags = ["firewall-wkld-internal-${var.environment}"]
  source_ranges = ["${var.processor_subnet_cidr}"]
}

resource "google_compute_firewall" "wkld-all" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-wkld-all"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["8080"]
  }
  target_tags = ["firewall-wkld-all-${var.environment}"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "proc-ipsec" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-proc-ipsec"
  network = "${var.network}"
  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }
  target_tags = ["firewall-proc-ipsec-${var.environment}"]
  source_ranges = ["${var.workload_subnet_cidr}"]
}

resource "google_compute_firewall" "proc-ipsec-proc-traffic" {
  count = "${var.enable == "true" ?  1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-proc-ipsec-proc-traffic"
  network = "${var.network}"
  allow {
    protocol = "udp"
    ports    = ["500", "4500"]
  }
  target_tags = ["firewall-proc-ipsec-proc-traffic-${var.environment}"]
  source_ranges = ["${var.all_processors_cidr}"]
}

resource "google_compute_firewall" "proc-icmp-proc-traffic" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-proc-icmp-proc-traffic"
  network = "${var.network}"
  allow {
    protocol = "icmp"
  }
  target_tags = ["firewall-proc-icmp-traffic-${var.environment}"]
  source_ranges = ["${var.all_processors_cidr}"]
}

resource "google_compute_firewall" "proc-icmp-wkld-traffic" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-proc-icmp-wkld-traffic"
  network = "${var.network}"
  allow {
    protocol = "icmp"
  }
  target_tags = ["firewall-proc-icmp-traffic-${var.environment}"]
  source_ranges = ["${var.workload_subnet_cidr}"]
}

resource "google_compute_firewall" "orch-internal" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-orch-internal"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["2376", "2377", "7946"]
  }
  allow {
    protocol = "udp"
    ports    = ["7946", "4789"]
  }
  target_tags = ["firewall-orch-internal-${var.environment}"]
  source_ranges = ["${var.orchestrator_subnet_cidr}"]
}

resource "google_compute_firewall" "ingress-proxy" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-firewall-ingress-proxy"
  network = "${var.network}"
  allow {
    protocol = "tcp"
    ports    = ["80", "443", "5045"]
  }
  target_tags = ["firewall-ingress-proxy-${var.environment}"]
  source_ranges = ["0.0.0.0/0"]
}
