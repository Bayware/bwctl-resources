output "vpc_id" {
  value = "${join("", aws_vpc.vpc.*.id)}"
}

output "orchestrator_subnet_id" {
  value = "${join("", aws_subnet.orchestrator_subnet.*.id)}"
}

output "workload_subnet_id" {
  value = "${join("", aws_subnet.workload_subnet.*.id)}"
}

output "processor_subnet_id" {
  value = "${join("", aws_subnet.processor_subnet.*.id)}"
}
