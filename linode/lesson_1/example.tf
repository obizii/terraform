# Before you begin this Terraform project, make sure you have your Linode API key 
# and you have created a terraform.tfvars with the correct variables

# Configure the Linode provider

terraform {
    required_providers {
        linode = {
            source = "linode/linode"
        }
    }
}

provider "linode" {
    token = var.linode_token
    api_version = "v4beta"
}

# linode

resource "linode_instance" "ex_instance" {
  label     = "example_instance"
  image     = "linode/ubuntu23.10"
  region    = "us-lax"
  type      = "g6-nanode-1"
  root_pass = var.root_pass

  provisioner "file" {
    source      = "setup_script.sh"
    destination = "/tmp/setup_script.sh"
    connection {
      type      = "ssh"
      host      = self.ip_address
      user      = "root"
      password  = var.root_pass
    }
  }

  provisioner "remote-exec" {
    inline = [ 
        "chmod +x /tmp/setup_script.sh",
        "/tmp/setup_script.sh",
        "sleep 1"
    ]
    connection {
      type      = "ssh"
      host      = self.ip_address
      user      = "root"
      password  = var.root_pass
    }
  }
}

# firewall

resource "linode_firewall" "example_firewall" {
  label = "example_firewall_label"
  inbound {
      label = "allow-http"
      action = "ACCEPT"
      protocol = "TCP"
      ports = "80"
      ipv4 = ["0.0.0.0/0"]
      ipv6 = ["ff00::/8"]
    }

  inbound_policy = "DROP"

  outbound_policy = "ACCEPT"

  linodes = [ linode_instance.ex_instance.id ]
}

# variables
variable "linode_token" {}
variable "root_pass" {}