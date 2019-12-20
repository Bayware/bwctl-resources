resource "azurerm_virtual_network" "network" {
  count = "${var.network_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}"
  address_space = ["${var.network_ip_cidr_range}"]
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tags {
    environment = "${var.environment}"
  }
}

resource "azurerm_subnet" "orchestrator_subnet" {
  count = "${var.orchestrator_subnet_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-orchestrator-subnet"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.orchestrator_subnet_cidr}"
  depends_on = [
    "azurerm_virtual_network.network"
  ]
}

resource "azurerm_subnet" "processor_subnet" {
  count = "${var.processor_subnet_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-processor-subnet"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.processor_subnet_cidr}"
  depends_on = [
    "azurerm_virtual_network.network",
    "azurerm_subnet.orchestrator_subnet"
  ]
}

resource "azurerm_subnet" "workload_subnet" {
  count = "${var.workload_subnet_enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-workload-subnet"
  resource_group_name = "${var.resource_group_name}"
  virtual_network_name = "${azurerm_virtual_network.network.name}"
  address_prefix = "${var.workload_subnet_cidr}"
  depends_on = [
    "azurerm_virtual_network.network",
    "azurerm_subnet.processor_subnet"
  ]
}
