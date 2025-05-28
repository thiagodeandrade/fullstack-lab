variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
  sensitive   = true
}

variable "ssh_fingerprint" {
  type        = string
  description = "SSH key fingerprint registered in DigitalOcean"
}