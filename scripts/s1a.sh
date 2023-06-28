export CONSUL_HTTP_ADDR=$(terraform output -raw consul-dc1-server-fqdn)
export CONSUL_HTTP_TOKEN=$(kubectl get secret -n consul consul-bootstrap-acl-token -ojson --context $S1a | jq .data.token -r | base64 -d)
