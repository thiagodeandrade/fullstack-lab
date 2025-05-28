output "jmeter_public_ip" {
  description = "Public IP address of the JMeter server"
  value       = digitalocean_droplet.jmeter.ipv4_address
}
output "DEBUG_app_server_ip" {
  value = var.app_server_ip
}