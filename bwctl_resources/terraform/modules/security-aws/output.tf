output "sg_wkld_id" {
  value = "${join("", aws_security_group.workloads.*.id)}"
}

output "sg_proc_id" {
  value = "${join("", aws_security_group.processors.*.id)}"
}

output "sg_orch_id" {
  value = "${join("", aws_security_group.orchestrators.*.id)}"
}

output "sg_proxy_id" {
  value = "${join("", aws_security_group.ingress_proxy.*.id)}"
}

output "key_name" {
  value = "${join("", aws_key_pair.key.*.key_name)}"
}
