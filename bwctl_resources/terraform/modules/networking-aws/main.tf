resource "aws_vpc" "vpc" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  cidr_block = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support = true

  tags {
    Name  = "${var.prefix}${var.suffix}"
    Environment = "${var.environment}"
  }
}

resource "aws_internet_gateway" "ig-public" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.prefix}${var.suffix}-igw"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "orchestrator_subnet" {
  count = "${var.orchestrator_subnet_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.orchestrator_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}${var.suffix}-orchestrator-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "workload_subnet" {
  count = "${var.workload_subnet_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.workload_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}${var.suffix}-workload-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_subnet" "processor_subnet" {
  count = "${var.processor_subnet_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  cidr_block = "${var.processor_subnet_cidr}"
  map_public_ip_on_launch = true

  tags {
    Name = "${var.prefix}${var.suffix}-processor-subnet"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "orchestrator" {
  count = "${var.orchestrator_subnet_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.prefix}${var.suffix}-orch-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "workload" {
  count = "${var.workload_subnet_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.prefix}${var.suffix}-wkld-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route_table" "processor" {
  count = "${var.processor_subnet_enable == "true" ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name = "${var.prefix}${var.suffix}-proc-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "orchestrator_route" {
  count = "${var.orchestrator_subnet_enable == "true" ? 1 : 0}"
  route_table_id = "${aws_route_table.orchestrator.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ig-public.id}"
}

resource "aws_route" "workload_route" {
  count = "${var.workload_subnet_enable == "true" ? 1 : 0}"
  route_table_id = "${aws_route_table.workload.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ig-public.id}"
}

resource "aws_route" "processor_route" {
  count = "${var.processor_subnet_enable == "true" ? 1 : 0}"
  route_table_id = "${aws_route_table.processor.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = "${aws_internet_gateway.ig-public.id}"
}

resource "aws_route_table_association" "orchestrator" {
  count = "${var.orchestrator_subnet_enable == "true" ? 1 : 0}"
  subnet_id = "${aws_subnet.orchestrator_subnet.id}"
  route_table_id = "${aws_route_table.orchestrator.id}"
}

resource "aws_route_table_association" "workload" {
  count = "${var.workload_subnet_enable == "true" ? 1 : 0}"
  subnet_id = "${aws_subnet.workload_subnet.id}"
  route_table_id = "${aws_route_table.workload.id}"
}

resource "aws_route_table_association" "processor" {
  count = "${var.processor_subnet_enable == "true" ? 1 : 0}"
  subnet_id = "${aws_subnet.processor_subnet.id}"
  route_table_id = "${aws_route_table.processor.id}"
}
