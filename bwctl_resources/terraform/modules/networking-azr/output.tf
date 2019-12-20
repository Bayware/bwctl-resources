output "orchestrator_subnet_id" {
  value = "${join("", azurerm_subnet.orchestrator_subnet.*.id)}"
}

output "workload_subnet_id" {
  value = "${join("", azurerm_subnet.workload_subnet.*.id)}"
}

output "processor_subnet_id" {
  value = "${join("", azurerm_subnet.processor_subnet.*.id)}"
}
