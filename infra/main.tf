provider "digitalocean" {
  token = var.do_token
}

resource "digitalocean_droplet" "app" {
  name   = "app-server"
  region = "nyc3"
  size   = "s-1vcpu-1gb"
  image  = "ubuntu-22-04-x64"

  ssh_keys = [var.ssh_fingerprint]

  tags = ["app"]

  user_data = file("${path.module}/provision.sh")
}