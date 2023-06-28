## Note
- Ensure Terminating Gateway ACL Token has write permssion for services.
- Services in a named partition trying to call external-service should have the partition name explicitly specified in the upstream service URL in transparent proxy mode.


## Deploy external-service
```
kubectl create ns external --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server && kubectl -n external apply -f examples/applications/external-service-demo-default/external-service.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```

## Register external service in DC2 cluster, default partition
```
export CONSUL_HTTP_TOKEN=$(kubectl get secrets -n consul consul-bootstrap-acl-token --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-server -ojson | jq ".data.token" -r | base64 -d)

export CONSUL_HTTP_ADDR=$(tfo -raw consul-dc1-server-fqdn)

#Register external-service
curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo-default/external-service.json  $CONSUL_HTTP_ADDR/v1/catalog/register

```


## Create secret with CA certificate (for HTTPs only)
kubectl create secret -n consul generic jsonplaceholder-ca --from-file=ca=examples/applications/external-service-demo-default/json-ca.crt

## Add below to helm for client admin partition (for HTTPs only)
terminatingGateways:
  enabled: true
  defaults:
    replicas: 1
    extraVolumes:
    - type: secret
      name: jsonplaceholder-ca
      items: 
      - key: ca
        path: my-ca 
  gateways:
    - name: https-terminating-gateway


## Upgrade helm (for HTTPs only)
helm upgrade tks-consul-server hashicorp/consul --namespace consul -f modules/consul/aws/consul-server/consul-server-helm-values.yml.tmp --version 0.45.0

## Apply Configurations
- Apply ```mesh.yml```
```
kubectl apply -f examples/applications/external-service-demo-default/mesh.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```

- Apply ```proxy-defaults.yaml```
```
kubectl apply -f examples/applications/external-service-demo-default/proxy-defaults.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```

- Apply ```terminating-gateway.yml```
```
kubectl apply -f examples/applications/external-service-demo-default/terminating-gateway.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```

- Apply ```external-service-intention.yml```
```
kubectl apply -f examples/applications/external-service-demo-default/external-service-intention.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```
- Apply ```web.yml```
```
kubectl label ns default consul=enabled --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-server
kubectl label ns default consul=enabled --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server

kubectl apply -f examples/applications/external-service-demo-default/web.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```


## Deregister External Services
- Remove services from terminating-gateway
```
kubectl apply -f examples/applications/external-service-demo-default/terminating-gateway-delete.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server

kubectl delete -f examples/applications/external-service-demo-default/web.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server

kubectl delete -f examples/applications/external-service-demo-default/external-service-intention.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```
- Deregister external services
```
export CONSUL_HTTP_TOKEN=$(kubectl get secrets -n consul consul-bootstrap-acl-token --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server -ojson | jq ".data.token" -r | base64 -d)

export CONSUL_HTTP_ADDR=$(tfo -raw consul-dc2-server-fqdn)

curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo-default/external-service-deregister.json  $CONSUL_HTTP_ADDR/v1/catalog/deregister
```


