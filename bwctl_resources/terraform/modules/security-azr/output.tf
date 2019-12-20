output "security_group_wkld" {
  value = "${join("", azurerm_network_security_group.workloads.*.id)}"
}

output "security_group_proc" {
  value = "${join("", azurerm_network_security_group.processors.*.id)}"
}

output "security_group_orch" {
  value = "${join("", azurerm_network_security_group.orchestrators.*.id)}"
}

output "security_group_ctrl" {
  value = "${join("", azurerm_network_security_group.controllers.*.id)}"
}
