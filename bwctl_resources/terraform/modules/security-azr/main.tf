resource "azurerm_network_security_group" "workloads" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-workloads-sg"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tags {
    environment = "${var.environment}"
  }
}
resource "azurerm_network_security_rule" "wkld_ssh_processors" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "SSH_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.workloads.name}"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.processor_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "wkld_getaway" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "GETAWAY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.workloads.name}"
  priority                    = 1011
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "8080"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "wkld_ipsec500_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "IPSEC500"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.workloads.name}"
  priority                    = 1020
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "500"
  source_address_prefix       = "${var.processor_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "wkld_ipsec4500_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "IPSEC4500"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.workloads.name}"
  priority                    = 1021
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4500"
  source_address_prefix       = "${var.processor_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "wkld_ping_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "PING_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.workloads.name}"
  priority                    = 1023
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_group" "processors" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-processors-sg"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tags {
    environment = "${var.environment}"
  }
}
resource "azurerm_network_security_rule" "proc_ssh_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "SSH_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 990
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ssh_bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "SSH_BASTION"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.bastion_ip}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ipsec500_wkld" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "IPSEC500_WKLD"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1020
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "500"
  source_address_prefix       = "${var.workload_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ipsec4500_wkld" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "IPSEC4500_WKLD"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1021
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4500"
  source_address_prefix       = "${var.workload_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ping_bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "PING_BASTION"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1022
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "${var.bastion_ip}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ping_wkld" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "PING_WKLD"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1023
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "${var.workload_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ping_proc" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "PING_PROC"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1024
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefixes     = ["${var.all_processors_cidr}"]
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ping_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "PING_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1025
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ipsec500_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "IPSEC500_PROC"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1030
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "500"
  source_address_prefixes     = ["${var.all_processors_cidr}"]
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "proc_ipsec4500_proc" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "IPSEC4500_PROC"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.processors.name}"
  priority                    = 1031
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "4500"
  source_address_prefixes     = ["${var.all_processors_cidr}"]
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_group" "orchestrators" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-orchestrators-sg"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tags {
    environment = "${var.environment}"
  }
}
resource "azurerm_network_security_rule" "orch_ssh_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "SSH_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 990
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_ssh_bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "SSH_BASTION"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.bastion_ip}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_2376" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM2376"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1024
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2376"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_2377" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM2377"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1025
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2377"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_7946" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM7946"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1026
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "7946"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_7946_udp" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM7946U"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1027
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "7946"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_4789" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM4789"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1028
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_ping_bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "PING"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1030
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "${var.bastion_ip}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "orch_ping_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "PING_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.orchestrators.name}"
  priority                    = 1031
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}

resource "azurerm_network_security_group" "controllers" {
  count = "${var.enable == "true" ? 1 : 0}"
  name = "${var.prefix}${var.suffix}-controllers-sg"
  location = "${var.location}"
  resource_group_name = "${var.resource_group_name}"
  tags {
    environment = "${var.environment}"
  }
}
resource "azurerm_network_security_rule" "ctrl_ssh_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "SSH_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 990
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_ssh_bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "SSH_BASTION"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "${var.bastion_ip}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_http" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "HTTP"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1011
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_https" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "HTTPS"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1012
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "443"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_elk" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "ELK"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1015
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "5045"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_2376" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM2376"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1024
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2376"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_2377" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM2377"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1025
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "2377"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_7946" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM7946"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1026
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "7946"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_7946_udp" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM7946U"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1027
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "udp"
  source_port_range           = "*"
  destination_port_range      = "7946"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_4789" {
  count = "${var.enable == "true" ? 1 : 0}"
  name                        = "DOCKER_SWARM4789"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1028
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "tcp"
  source_port_range           = "*"
  destination_port_range      = "4789"
  source_address_prefix       = "${var.orchestrator_subnet_cidr}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_ping_bastion" {
  count = "${var.enable == "true" && var.production == "true" ? 1 : 0}"
  name                        = "PING"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1030
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "${var.bastion_ip}"
  destination_address_prefix  = "*"
}
resource "azurerm_network_security_rule" "ctrl_ping_any" {
  count = "${var.enable == "true" && var.production == "false" ? 1 : 0}"
  name                        = "PING_ANY"
  resource_group_name         = "${var.resource_group_name}"
  network_security_group_name = "${azurerm_network_security_group.controllers.name}"
  priority                    = 1031
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "0"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
}
