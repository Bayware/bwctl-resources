data "aws_ami" "vm" {
  name_regex = "${var.instance_ami_pattern}"
  owners = ["490531118610"]
  most_recent = true
}

resource "aws_instance" "vm" {
  count          = "${var.instance_enable == "true" ? 1 : 0}"
  ami            = "${data.aws_ami.vm.id}"
  instance_type  = "${var.instance_type}"
  subnet_id      = "${var.public_subnet_id}"
  associate_public_ip_address = true
  source_dest_check = false
  root_block_device {
    volume_size  = "${var.instance_disk_size}"
    delete_on_termination = true
  }
  vpc_security_group_ids = [
    "${var.sg_ids}"
  ]
  key_name       = "${var.key_name}"
  user_data = <<-AWSEOF
    #!/bin/bash
    adduser ${var.user_name}
    grep ^wheel: /etc/group && usermod -aG wheel ${var.user_name}
    grep ^sudo: /etc/group && usermod -aG sudo ${var.user_name}
    mkdir /home/${var.user_name}/.ssh
    chmod 700 /home/${var.user_name}/.ssh
    touch /home/${var.user_name}/.ssh/authorized_keys
    chmod 600 /home/${var.user_name}/.ssh/authorized_keys
    chown -R ${var.user_name}:${var.user_name} /home/${var.user_name}/.ssh
    echo "${file(var.key_file)}" >> /home/${var.user_name}/.ssh/authorized_keys
    echo "${var.user_name} ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/10-bwctl-user
    AWSEOF
  lifecycle {
    ignore_changes = ["ami"]
  }
  tags = {
    Name         = "${var.prefix}${var.suffix}"
    Environment  = "${var.environment}"
  }
}
