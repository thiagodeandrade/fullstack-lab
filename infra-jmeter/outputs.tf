output "jmeter_public_ip" {
  description = "Public IP address of the JMeter server"
  value       = digitalocean_droplet.jmeter.ipv4_address
}
output "ip_address" {
  value = digitalocean_droplet.app.ipv4_address
}
output "jmeter_ip" {
  value = digitalocean_droplet.jmeter.ipv4_address
}