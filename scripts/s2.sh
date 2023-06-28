export CONSUL_HTTP_ADDR=$(terraform output -raw consul-dc2-server-fqdn)
export CONSUL_HTTP_TOKEN=$(kubectl get secret -n consul consul-bootstrap-acl-token -ojson --context $S2 | jq .data.token -r | base64 -d)
