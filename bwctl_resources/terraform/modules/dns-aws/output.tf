output "fqdn" {
  value = "${join("", aws_route53_record.a.*.fqdn)}"
}
