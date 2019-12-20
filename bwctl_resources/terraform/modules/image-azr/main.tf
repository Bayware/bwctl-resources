data "azurerm_shared_image" "image" {
  count               = "${var.marketplace_enable == "false" ? 1 : 0}"
  name                = "${var.image_pattern}"
  gallery_name        = "${var.image_tag}"
  resource_group_name = "${var.resource_group_name}"
}
