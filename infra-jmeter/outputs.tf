output "jmeter_public_ip" {
  description = "Endereço IP público do droplet JMeter"
  value       = digitalocean_droplet.jmeter.ipv4_address
}