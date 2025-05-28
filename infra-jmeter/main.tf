provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "jmeter" {
  name   = "jmeter-server"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"

  ssh_keys = [var.ssh_fingerprint]
  tags     = ["jmeter"]

  user_data = file("${path.module}/provision.sh")
}

output "jmeter_public_ip" {
  value = digitalocean_droplet.jmeter.ipv4_address
}