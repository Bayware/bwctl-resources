variable "vpc_id" {
}

variable "environment" {
}

variable "key_name" {
}

variable "key_path" {
}

variable "enable" {
}

variable "prefix" {
}

variable "suffix" {
}

variable "production" {
}

variable "bastion_ip" {
}

variable "orchestrator_subnet_cidr" {
}

variable "workload_subnet_cidr" {
}

variable "processor_subnet_cidr" {
}

variable "all_processors_cidr" {
  type = "list"
}
