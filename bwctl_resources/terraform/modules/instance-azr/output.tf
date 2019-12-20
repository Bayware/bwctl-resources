output "public_ip" {
  value = "${join("", azurerm_public_ip.public-ip.*.ip_address)}"
}

output "private_ip" {
  value = "${join("", azurerm_network_interface.nic.*.private_ip_address)}"
}
