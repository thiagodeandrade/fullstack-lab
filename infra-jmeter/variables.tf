variable "do_token" {
  type        = string
  description = "DigitalOcean API token"
}

variable "ssh_fingerprint" {
  type        = string
  description = "SSH fingerprint configurado na conta DigitalOcean"
}

variable "app_server_ip" {
  type        = string
  description = "IP público do app-server para o JMeter testar"
}