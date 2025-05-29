terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "jmeter" {
  name   = "jmeter-server"
  region = "nyc3"
  size = "s-1vcpu-2gb"
  image  = "ubuntu-22-04-x64"

  ssh_keys = [var.ssh_fingerprint]
  tags     = ["jmeter"]

  user_data = templatefile("${path.module}/provision.sh.tpl", {
    app_server_ip = var.app_server_ip
    load_test_jmx = file("${path.module}/../jmeter/load-test.jmx")
  })
}