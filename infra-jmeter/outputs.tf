output "jmeter_public_ip" {
  description = "Public IP address of the JMeter server"
  value       = digitalocean_droplet.jmeter.ipv4_address
}