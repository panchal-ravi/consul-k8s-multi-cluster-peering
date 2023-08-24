output "ui_public_fqdn" {
  description = "Consul ui public fqdn"
  value       = data.kubernetes_service.consul-ui.status.0.load_balancer.0.ingress.0.hostname
}

output "partition_public_fqdn" {
  description = "Consul ui public fqdn"
  value       = data.kubernetes_service.consul-partition.status.0.load_balancer.0.ingress.0.hostname
  /* value = data.kubernetes_service.consul-expose-servers.status.0.load_balancer.0.ingress.0.hostname */
}

output "private_fqdn" {
  description = "Consul Private fqdn"
  value       = data.kubernetes_pod.consul-server.spec.0.node_name
}

output "ca-cert" {
  description = "Consul server ca certificate"
  value       = data.kubernetes_secret.consul-ca-cert.data
}

output "ca-key" {
  description = "Consul server ca key"
  value       = data.kubernetes_secret.consul-ca-key.data
}

output "consul_partitions_acl_token" {
  description = "Consul server partition ACL token"
  value       = data.kubernetes_secret.consul-partitions-acl-token.data
}

output "consul-bootstrap-acl-token" {
  description = "Consul server bootstrap ACL token"
  value       = data.kubernetes_secret.consul-bootstrap-acl-token.data
  sensitive   = true
}