resource "consul_acl_policy" "external_service" {
  name        = "external-service-policy"
  datacenters = ["${var.datacenter}"]
  rules       = <<-RULE
    partition "default" {
        namespace "default" {
            service "external-service" {
                policy = "write"
            }
        }
    }
    RULE
}

data "consul_acl_role" "terminating_gateway_role" {
  name = "consul-terminating-gateway-acl-role"
}

data "consul_acl_policy" "terminating_gateway_policy" {
  name = "terminating-gateway-policy"
}

resource "null_resource" "update_terminating_gateway_acl_role" {
  provisioner "local-exec" {
    command = <<-EOT
         export CONSUL_HTTP_TOKEN=${var.consul_token}
         export CONSUL_HTTP_ADDR=https://${var.consul_addr}
         export CONSUL_HTTP_SSL_VERIFY=false
         consul acl role update -id ${data.consul_acl_role.terminating_gateway_role.id} -policy-id=${consul_acl_policy.external_service.id}
      EOT
  }
  depends_on = [consul_acl_policy.external_service, data.consul_acl_role.terminating_gateway_role]
}

/* 
// This does not work as Consul doesn't allow to overwrite existing role
resource "consul_acl_role" "terminating_gateway_role" {
  name        = "consul-terminating-gateway-acl-role"
  description = "ACL Role for consul-terminating-gateway"
  policies    = concat(["${consul_acl_policy.external_service.id}"], data.consul_acl_role.terminating_gateway_role.policies[*].id)

  depends_on = [data.consul_acl_role.terminating_gateway_role]
} */

