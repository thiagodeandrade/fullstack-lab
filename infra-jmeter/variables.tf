variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
}

variable "ssh_fingerprint" {
  description = "SSH key fingerprint to access the droplet"
  type        = string
}

variable "app_server_ip" {
  description = "Public IP of the app-server to test against"
  type        = string
}