output "network" {
  value = "${join("", google_compute_network.network.*.self_link)}"
}

output "orchestrator_subnet_id" {
  value = "${join("", google_compute_subnetwork.orchestrator_subnet.*.self_link)}"
}

output "workload_subnet_id" {
  value = "${join("", google_compute_subnetwork.workload_subnet.*.self_link)}"
}

output "processor_subnet_id" {
  value = "${join("", google_compute_subnetwork.processor_subnet.*.self_link)}"
}
