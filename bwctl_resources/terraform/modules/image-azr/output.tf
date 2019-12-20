output "image_id" {
  value = "${join("", data.azurerm_shared_image.image.*.id)}"
}
