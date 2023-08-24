 curl -kv -X PUT -H "X-Consul-Token:$CONSUL_HTTP_TOKEN" --data @./modules/consul/aws/consul-acl/update_role_payload.json $CONSUL_HTTP_ADDR/v1/acl/role/ca104038-4b2d-b4c4-f920-ba17d16a5045

 #curl -kv -X PUT --data @${path.module}/update_role_payload.json ${var.consul_addr}/v1/acl/role/${data.consul_acl_role.terminating_gateway_role.id}