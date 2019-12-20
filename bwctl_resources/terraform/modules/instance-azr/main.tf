resource "azurerm_public_ip" "public-ip" {
  count = "${var.instance_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-public-ip"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  allocation_method = "Dynamic"
  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_network_interface" "nic" {
  count = "${var.instance_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-nic"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_security_group_id  = "${var.security_group}"
  enable_ip_forwarding = true
  enable_accelerated_networking = "${var.accelerated_networking}"
  ip_configuration {
    name = "${var.prefix}${var.suffix}-nic"
    subnet_id = "${var.subnet}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = "${element(azurerm_public_ip.public-ip.*.id, count.index)}"
  }
  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_virtual_machine" "vm" {
  count = "${var.instance_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  network_interface_ids = ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
  vm_size = "${var.instance_type}"
  delete_os_disk_on_termination = true
  storage_os_disk {
    name = "${var.prefix}${var.suffix}-disk"
    caching = "ReadWrite"
    create_option = "FromImage"
    managed_disk_type = "${var.disk_type}"
    disk_size_gb = "${var.disk_size}"
  }
  storage_image_reference {
    id = "${var.image_id}"
  }
  os_profile {
    computer_name = "${var.prefix}${var.suffix}"
    admin_username = "${var.ssh_user}"
  }
  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.ssh_user}/.ssh/authorized_keys"
      key_data = "${file(var.ssh_pub_key_file)}"
    }
  }
  lifecycle {
    ignore_changes = ["storage_image_reference"]
  }
  tags {
    environment = "${var.environment}"
  }
}
