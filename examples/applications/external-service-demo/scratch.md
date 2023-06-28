## Ensure Terminating Gateway ACL Token has write permssion for services.

## Deploy external-service
```
kubectl apply -f examples/applications/external-service-demo/fake-service.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```

## Register external service in DC2 cluster, finance partition
```
export CONSUL_HTTP_TOKEN=$(kubectl get secrets -n consul consul-bootstrap-acl-token --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server -ojson | jq ".data.token" -r | base64 -d)

export CONSUL_HTTP_ADDR=$(tfo -raw consul-dc2-server-fqdn)

#Register fake-service
curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo/external-service-fake.json  $CONSUL_HTTP_ADDR/v1/catalog/register
```


## Create secret with CA certificate (for HTTPs only)
kubectl create secret -n consul generic jsonplaceholder-ca --from-file=ca=examples/applications/external-service-demo/json-ca.crt

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
kubectl apply -f examples/applications/external-service-demo/mesh.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl apply -f examples/applications/external-service-demo/mesh.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

- Apply ```proxy-defaults.yaml```
```
kubectl apply -f examples/applications/external-service-demo/proxy-defaults.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl apply -f examples/applications/external-service-demo/proxy-defaults.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

- Apply ```terminating-gateway.yml```
```
kubectl apply -f examples/applications/external-service-demo/terminating-gateway.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

- Apply ```external-service-https-intentions.yml```
```
kubectl apply -f examples/applications/external-service-demo/external-service-http-intentions.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```
- Apply ```external-fake-service-intention.yml```
```
kubectl apply -f examples/applications/external-service-demo/external-fake-service-intention.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```
- Apply ```frontend.yml```
```
kubectl apply -f examples/applications/external-service-demo/frontend.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

## Appy terminating-gateway.yml
```
kubectl apply -f examples/applications/external-service-demo/terminating-gateway.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

## Deregister External Services
- Remove services from terminating-gateway
```
kubectl apply -f examples/applications/external-service-demo/terminating-gateway-delete.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete -f examples/applications/external-service-demo/frontend.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete -f examples/applications/external-service-demo/external-service-http-intentions.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete -f examples/applications/external-service-demo/external-service-fake-intention.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```
- Deregister external services
```
export CONSUL_HTTP_TOKEN=$(kubectl get secrets -n consul consul-bootstrap-acl-token --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server -ojson | jq ".data.token" -r | base64 -d)

export CONSUL_HTTP_ADDR=$(tfo -raw consul-dc2-server-fqdn)

curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo/external-service-deregister-http.json  $CONSUL_HTTP_ADDR/v1/catalog/deregister

curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo/external-service-deregister-fake-service.json  $CONSUL_HTTP_ADDR/v1/catalog/deregister
```