resource "aws_key_pair" "key" {
  count = "${var.enable == "true" ? 1 : 0}"
  key_name = "${var.prefix}${var.suffix}-${var.key_name}"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_security_group" "workloads" {
  count = "${var.enable == "true" ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  name = "${var.prefix}${var.suffix}-workloads-sg"
  description = "Allow traffic to workloads"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "ipsec_processors_wkld" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 500
  to_port       = 500
  protocol      = "udp"
  cidr_blocks   = ["${var.processor_subnet_cidr}"]
  security_group_id = "${aws_security_group.workloads.id}"
}

resource "aws_security_group_rule" "ipsec2_processors_wkld" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 4500
  to_port       = 4500
  protocol      = "udp"
  cidr_blocks   = ["${var.processor_subnet_cidr}"]
  security_group_id = "${aws_security_group.workloads.id}"
}

resource "aws_security_group_rule" "outgoing_wkld" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.workloads.id}"
}

resource "aws_security_group_rule" "ssh_processors_wkld" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks   = ["${var.processor_subnet_cidr}"]
  security_group_id = "${aws_security_group.workloads.id}"
}

resource "aws_security_group_rule" "getaway_any_wkld" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  type          = "ingress"
  from_port     = 8080
  to_port       = 8080
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.workloads.id}"
}

resource "aws_security_group_rule" "icmp_any_wkld" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  type          = "ingress"
  from_port     = 8
  to_port       = 0
  protocol      = "icmp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.workloads.id}"
}

resource "aws_security_group" "processors" {
  count = "${var.enable == "true" ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  name = "${var.prefix}${var.suffix}-processors-sg"
  description = "Allow traffic to processors"

  tags {
    Environment = "${var.environment}"
  }
}
resource "aws_security_group_rule" "ssh_bastion_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks   = ["${var.bastion_ip}/32"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "icmp_bastion_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port   = 8
  to_port     = 0
  protocol      = "icmp"
  cidr_blocks   = ["${var.bastion_ip}/32"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "ipsec_wkld_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 500
  to_port       = 500
  protocol      = "udp"
  cidr_blocks   = ["${var.workload_subnet_cidr}"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "ipsec2_wkld_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 4500
  to_port       = 4500
  protocol      = "udp"
  cidr_blocks   = ["${var.workload_subnet_cidr}"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "icmp_wkld_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port   = 8
  to_port     = 0
  protocol      = "icmp"
  cidr_blocks   = ["${var.workload_subnet_cidr}"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "outgoing_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "ssh_any_proc" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  type          = "ingress"
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "icmp_any_proc" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  type          = "ingress"
  from_port     = 8
  to_port       = 0
  protocol      = "icmp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "ipsec_proc_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 500
  to_port       = 500
  protocol      = "udp"
  cidr_blocks   = ["${var.all_processors_cidr}"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "ipsec2_proc_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 4500
  to_port       = 4500
  protocol      = "udp"
  cidr_blocks   = ["${var.all_processors_cidr}"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group_rule" "icmp_proc_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port   = 8
  to_port     = 0
  protocol      = "icmp"
  cidr_blocks   = ["${var.all_processors_cidr}"]
  security_group_id = "${aws_security_group.processors.id}"
}

resource "aws_security_group" "orchestrators" {
  count = "${var.enable == "true" ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  name = "${var.prefix}${var.suffix}-orchestrators-sg"
  description = "Allow traffic to orchestrators"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "ssh_bastion_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks   = ["${var.bastion_ip}/32"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "icmp_bastion_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 8
  to_port       = 0
  protocol      = "icmp"
  cidr_blocks   = ["${var.bastion_ip}/32"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "swarm_orch_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 2376
  to_port       = 2376
  protocol      = "tcp"
  cidr_blocks   = ["${var.orchestrator_subnet_cidr}"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "swarm2_orch_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 2377
  to_port       = 2377
  protocol      = "tcp"
  cidr_blocks   = ["${var.orchestrator_subnet_cidr}"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "swarm3_orch_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 7946
  to_port       = 7946
  protocol      = "tcp"
  cidr_blocks   = ["${var.orchestrator_subnet_cidr}"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "swarm4_orch_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 7946
  to_port       = 7946
  protocol      = "udp"
  cidr_blocks   = ["${var.orchestrator_subnet_cidr}"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "swarm5_orch_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 4789
  to_port       = 4789
  protocol      = "udp"
  cidr_blocks   = ["${var.orchestrator_subnet_cidr}"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "outgoing_orch" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "egress"
  from_port     = 0
  to_port       = 0
  protocol      = "-1"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "ssh_any_orch" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  type          = "ingress"
  from_port     = 22
  to_port       = 22
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group_rule" "icmp_any_orch" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  type          = "ingress"
  from_port     = 8
  to_port       = 0
  protocol      = "icmp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.orchestrators.id}"
}

resource "aws_security_group" "ingress_proxy" {
  count = "${var.enable == "true" ? 1 : 0}"
  vpc_id = "${var.vpc_id}"
  name = "${var.prefix}${var.suffix}-ingress-proxy-sg"
  description = "Allow traffic to ingress proxy"

  tags {
    Environment = "${var.environment}"
  }
}

resource "aws_security_group_rule" "http_any_proxy" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 80
  to_port       = 80
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ingress_proxy.id}"
}

resource "aws_security_group_rule" "https_any_proxy" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 443
  to_port       = 443
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ingress_proxy.id}"
}

resource "aws_security_group_rule" "logstash_any_proxy" {
  count = "${var.enable == "true" ? 1 : 0}"
  type          = "ingress"
  from_port     = 5045
  to_port       = 5045
  protocol      = "tcp"
  cidr_blocks   = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.ingress_proxy.id}"
}
