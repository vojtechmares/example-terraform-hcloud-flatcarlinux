data "hcloud_ssh_key" "vojtechmares" {
  name = "iam@vojtechmares.com"
}

locals {
  ssh_authorized_keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEUz21xFatGKfSwjeg/BOBus2Jn17o8xVthrMFAsDtRD iam@vojtechmares.com"]
}

resource "hcloud_server" "vm" {
  name     = "flatcar-linux-test"
  ssh_keys = [data.hcloud_ssh_key.vojtechmares.id]
  rescue   = "linux64"
  image    = "debian-10"

  server_type = "cx21"
  datacenter  = "nbg1-dc3"

  connection {
    host    = self.ipv4_address
    timeout = "1m"
  }

  provisioner "file" {
    content     = data.ct_config.ignition.rendered
    destination = "/root/ignition.json"
  }

  provisioner "remote-exec" {
    inline = [
      "set -ex",
      "apt update",
      "apt install -y gawk",
      "curl -fsSLO --retry-delay 1 --retry 60 --retry-connrefused --retry-max-time 60 --connect-timeout 20 https://raw.githubusercontent.com/kinvolk/init/flatcar-master/bin/flatcar-install",
      "chmod +x flatcar-install",
      "./flatcar-install -s -i /root/ignition.json",
      "shutdown -r +1",
    ]
  }

  provisioner "remote-exec" {
    connection {
      host    = self.ipv4_address
      timeout = "3m"
      user    = "core"
    }

    inline = [
      "sudo hostnamectl set-hostname ${self.name}",
    ]
  }
}

data "ct_config" "ignition" {
  content = templatefile("./cl/machine.yaml.tpl", { ssh_authorized_keys = jsonencode(var.ssh_authorized_keys), name = "flatcar-linux-test" }).rendered
}

# data "template_file" "machine-configs" {
#   for_each = toset(var.machines)
#   template = file("${path.module}/cl/machine-${each.key}.yaml.tmpl")

#   vars = {
#     ssh_keys = jsonencode(var.ssh_keys)
#     name     = each.key
#   }
# }
