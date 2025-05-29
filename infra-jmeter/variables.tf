variable "app_server_ip" {
  description = "IP público do app-server"
  type        = string
}

variable "load_test_jmx" {
  type        = string
  description = "Conteúdo do JMX para teste de carga"
}
