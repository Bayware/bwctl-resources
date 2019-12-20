resource "null_resource" "bastion" {
  count = "${var.enable == "true" ? 1 : 0}"
  triggers {
    random_uuid = "${uuid()}"
  }
  provisioner "local-exec" {
    command = "wget -O ./terraform.py https://raw.githubusercontent.com/nbering/terraform-inventory/master/terraform.py && chmod +x ./terraform.py && touch ./ansible_inventory"
  }
  provisioner "file" {
    source = "${var.key_file}"
    destination = "/home/${var.user_name}/.ssh/id_rsa"
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.user_name}/.bwctl"
    ]
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
  provisioner "file" {
    source = "../../ansible"
    destination = "/home/${var.user_name}/.bwctl"
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
  provisioner "file" {
    source = "../../terraform"
    destination = "/home/${var.user_name}/.bwctl"
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
   provisioner "file" {
    source = "./ansible_inventory"
    destination = "/home/${var.user_name}/.bwctl/ansible/ansible_inventory"
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
  provisioner "file" {
    source = "./ansible_inventory.sh"
    destination = "/home/${var.user_name}/.bwctl/ansible/ansible_inventory.sh"
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
  provisioner "remote-exec" {
    inline = [
      "sudo chmod 0600 /home/${var.user_name}/.ssh/id_rsa",
      "sudo chmod +x /home/${var.user_name}/.bwctl/terraform/*/.terraform/plugins/linux_amd64/terraform-provider*",
      "sudo chmod +x /home/${var.user_name}/.bwctl/*/*.sh"
    ]
    connection {
      type     = "ssh"
      host     = "${var.public_ip}"
      user     = "${var.user_name}"
      private_key = "${file(var.key_file)}"
      timeout  = "1m"
    }
  }
}
