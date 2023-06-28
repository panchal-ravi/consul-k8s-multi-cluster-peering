## Deploy backend app in "default" partition in dc1a datacenter and export it to dc2
```
kubectl label ns default consul=enabled --context $S1a
kubectl apply -f examples/applications/multi-peers-default/backend/backend-v1-dc1a-default.yml --context $S1a
kubectl apply -f examples/applications/multi-peers-default/backend/export-service-backend-dc1a-to-dc2.yml --context $S1a
kubectl apply -f examples/applications/multi-peers-default/backend/service-intentions-dc1a.yaml --context $S1a
```

## Deploy backend app in "default" partition in dc1b datacenter and export it to dc2
```
kubectl label ns default consul=enabled --context $S1b
kubectl apply -f examples/applications/multi-peers-default/backend/backend-v1-dc1b-default.yml --context $S1b
kubectl apply -f examples/applications/multi-peers-default/backend/export-service-backend-dc1b-to-dc2.yml --context $S1b
kubectl apply -f examples/applications/multi-peers-default/backend/service-intentions-dc1b.yaml --context $S1b
```


## Deploy frontend app in "default" partition in dc2 datacenter
- Create backend virtual service
```
kubectl apply -f examples/applications/multi-peers-default/frontend/backend1a-resolver.yml --context $S2
kubectl apply -f examples/applications/multi-peers-default/frontend/backend1b-resolver.yml --context $S2
kubectl apply -f examples/applications/multi-peers-default/frontend/backend-failover.yml --context $S2
kubectl apply -f examples/applications/multi-peers-default/frontend/backend-splitter.yml --context $S2
kubectl apply -f examples/applications/multi-peers-default/frontend/backend-retry.yml --context $S2
```
- Apply ```frontend.yml```
```
kubectl apply -f examples/applications/multi-peers-default/frontend/frontend.yml --context $S2
kubectl apply -f examples/applications/multi-peers-default/frontend/service-intentions-backend.yml --context $S2
```
- Apply ```ingress-gateways.yml```
```
kubectl apply -f examples/applications/multi-peers-default/frontend/ingress-gateway.yml --context $S2
```


## Test application
```
while true; do k exec -i $(kubectl get po -oname) -c frontend -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.body),\(.code)"' -r; sleep 1; done
curl http://$(kubectl get svc -n consul -l component=ingress-gateway --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-eepvktkz-dc1-server  -ojson  | jq ".items[].status.loadBalancer.ingress[].hostname" -r)
```

## Delete services and configuration
```
kubectl delete -f examples/applications/multi-peers-default/backend/export-service-backend-dc1b-to-dc2.yml --context $S1b
kubectl delete -f examples/applications/multi-peers-default/backend/service-intentions-dc1b.yaml --context $S1b
kubectl delete -f examples/applications/multi-peers-default/backend/backend-v1-dc1b-default.yml --context $S1b
kubectl delete -f examples/applications/multi-peers-default/backend/export-service-backend-dc1a-to-dc2.yml --context $S1a
kubectl delete -f examples/applications/multi-peers-default/backend/service-intentions-dc1a.yaml --context $S1a
kubectl delete -f examples/applications/multi-peers-default/backend/backend-v1-dc1a-default.yml --context $S1a

kubectl delete -f examples/applications/multi-peers-default/frontend/frontend.yml --context $S2
kubectl delete -f examples/applications/multi-peers-default/frontend/backend1a-resolver.yml --context $S2
kubectl delete -f examples/applications/multi-peers-default/frontend/backend1b-resolver.yml --context $S2
kubectl delete -f examples/applications/multi-peers-default/frontend/backend-failover.yml --context $S2
kubectl delete -f examples/applications/multi-peers-default/frontend/backend-splitter.yml --context $S2
kubectl delete -f examples/applications/multi-peers-default/frontend/backend-retry.yml --context $S2

tfd -target module.consul-dc2-server -auto-approve
tfd -target module.consul-dc1-serverb -auto-approve
tfd -target module.consul-dc1-server -auto-approve

kubectl delete ns consul --context $S1a
kubectl delete ns consul --context $S1b
kubectl delete ns consul --context $S2
```