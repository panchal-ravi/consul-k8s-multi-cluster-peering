## Note
- Ensure Terminating Gateway ACL Token has write permssion for services.
- Services in a named partition trying to call external-service should have the partition name explicitly specified in the upstream service URL in transparent proxy mode.


## Deploy external-service
```
kubectl create ns external --context $S1a && kubectl -n external apply -f examples/applications/external-service-demo-default/external-service.yml --context $S1a
```

## Register external service in DC2 cluster, default partition
```
export CONSUL_HTTP_TOKEN=$(kubectl get secrets -n consul consul-bootstrap-acl-token -ojson --context $S1a | jq ".data.token" -r | base64 -d)

export CONSUL_HTTP_ADDR=$(tfo -raw consul-dc1-server-fqdn)

# Update Address field with LB URL in external-service.json file
# kgs -n external external-service -ojson  | jq ".status.loadBalancer.ingress[].hostname" -r

#Register external-service or create service-defaults entry for external-service
curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo-default/external-service.json  $CONSUL_HTTP_ADDR/v1/catalog/register

#OR
kubectl apply -f examples/applications/external-service-demo-default/external-service-default.yml --context $S1a


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
- Apply ```mesh.yml```. Allow all traffic to flow only through service mesh. No direct external traffic will be allowed.  
```
kubectl apply -f examples/applications/external-service-demo-default/mesh.yml --context $S1a
```

- Apply ```proxy-defaults.yaml```
```
kubectl apply -f examples/applications/external-service-demo-default/proxy-defaults.yml --context $S1a
```

- Apply ```terminating-gateway.yml```
```
kubectl apply -f examples/applications/external-service-demo-default/terminating-gateway.yml --context $S1a
```

- Apply ```external-service-intention.yml```
```
# Confirm peer-name
kubectl apply -f examples/applications/external-service-demo-default/external-service-intention.yml --context $S1a
```
- Apply ```web.yml```
```
kubectl label ns default consul=enabled --context $S1a
kubectl label ns default consul=enabled --context $S2

kubectl apply -f examples/applications/external-service-demo-default/web.yml --context $S1a
```

- Apply ```frontend.yml```
```
#Check the UPSTREAM_URIS
kubectl apply -f examples/applications/external-service-demo-default/frontend.yml --context $S1a
```

## Deregister External Services
- Remove services from terminating-gateway
```
kubectl apply -f examples/applications/external-service-demo-default/terminating-gateway-delete.yml --context $S2
kubectl delete -f examples/applications/external-service-demo-default/external-service-intention.yml --context $S2
```

- Deregister external services
```
export CONSUL_HTTP_TOKEN=$(kubectl get secrets -n consul consul-bootstrap-acl-token --context $S1a -ojson | jq ".data.token" -r | base64 -d)
export CONSUL_HTTP_ADDR=$(tfo -raw consul-dc1-server-fqdn)
curl -k -X PUT -H "X-CONSUL-TOKEN: $CONSUL_HTTP_TOKEN" --data @examples/applications/external-service-demo-default/external-service-deregister.json  $CONSUL_HTTP_ADDR/v1/catalog/deregister
```

- Delete services in DC2
```
kubectl delete -n external -f examples/applications/external-service-demo-default/external-service.yml --context $S2
kubectl delete -f examples/applications/external-service-demo-default/backend-v1-dc2-default.yml --context $S2
kubectl delete -f examples/applications/external-service-demo-default/web.yml --context $S2
kubectl delete -f examples/applications/external-service-demo-default/frontend.yml --context $S1a

```

