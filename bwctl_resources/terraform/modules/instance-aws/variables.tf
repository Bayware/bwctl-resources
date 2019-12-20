variable "instance_enable" {
}

variable "instance_type" {
}

variable "instance_disk_size" {
}

variable "instance_ami_pattern" {
}

variable "region" {
}

variable "public_subnet_id" {
}

variable "user_name" {
}

variable "key_name" {
}

variable "key_file" {
}

variable "environment" {
}

variable "vpc_id" {
}

variable "prefix" {
}

variable "suffix" {
}

variable "description" {
}

variable "ansible_groups" {
  type = "list"
}

variable "sg_ids" {
  type = "list"
}
