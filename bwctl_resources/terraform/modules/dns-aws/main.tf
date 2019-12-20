data "aws_route53_zone" "selected" {
  name         = "${var.dns_managed_zone_domain}"
  private_zone = false
}

resource "aws_route53_record" "a" {
  count   = "${var.dns_enable == "true" ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.selected.zone_id}"
  name    = "${var.name}.${data.aws_route53_zone.selected.name}"
  type    = "A"
  ttl     = "300"
  records = ["${var.ip_address}"]
}
