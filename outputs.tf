output "consul-dc1-server-fqdn" {
  description = "Consul DC #1 Server"
  value       = "https://${module.consul-dc1-server.ui_public_fqdn}"
}

output "consul-dc1-serverb-fqdn" {
  description = "Consul DC #1 ServerB"
  value       = "https://${module.consul-dc1-serverb.ui_public_fqdn}"
}


output "consul-dc2-server-fqdn" {
  description = "Consul DC #2 Server"
  value       = "https://${module.consul-dc2-server.ui_public_fqdn}"
}

/* output "cluster_oidc_issuer_urls" {
  value = module.infra-aws.cluster_oidc_issuer_url
} */

output "deployment_id" {
  value = local.deployment_id
}

/* output "bastion_ip" {
  value = module.infra-aws.bastion_ip
} */