## Deploy product app in "default" partition in dc1a datacenter and export it to dc2
```
kubectl label ns default consul=enabled --context $S1a
kubectl apply -f examples/applications/pcss-demo/product/product-v1-dc1a-default.yml --context $S1a
kubectl apply -f examples/applications/pcss-demo/product/export-service-product-dc1a-to-dc2.yml --context $S1a
kubectl apply -f examples/applications/pcss-demo/product/service-intentions-dc1a.yaml --context $S1a
```


## Deploy search and product app in "default" partition in dc2 datacenter
- Deploy product local service in dc2
kubectl apply -f examples/applications/pcss-demo/search/product-v1-local.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/product-v1-local-failing.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/product-v1-local-failing-health.yml --context $S2

- Create product virtual service
```
kubectl apply -f examples/applications/pcss-demo/search/product-failover.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/product1a-resolver.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/product-splitter.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/product-retry.yml --context $S2
```
- Apply ```search.yml```
```
kubectl apply -f examples/applications/pcss-demo/search/search.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/service-intentions-product.yml --context $S2
```
- Apply ```ingress-gateways.yml```
```
kubectl apply -f examples/applications/pcss-demo/search/ingress-gateway.yml --context $S2
```


## Test application
```
while true; do kubectl exec -i $(kubectl get pod -l app=search -oname) -c search -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done

curl http://$(kubectl get svc -n consul -l component=ingress-gateway --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-eepvktkz-dc1-server  -ojson  | jq ".items[].status.loadBalancer.ingress[].hostname" -r)
```

## Delete services and configuration
```
kubectl delete -f examples/applications/pcss-demo/product/export-service-product-dc1b-to-dc2.yml --context $S1b
kubectl delete -f examples/applications/pcss-demo/product/service-intentions-dc1b.yaml --context $S1b
kubectl delete -f examples/applications/pcss-demo/product/product-v1-dc1b-default.yml --context $S1b
kubectl delete -f examples/applications/pcss-demo/product/export-service-product-dc1a-to-dc2.yml --context $S1a
kubectl delete -f examples/applications/pcss-demo/product/service-intentions-dc1a.yaml --context $S1a
kubectl delete -f examples/applications/pcss-demo/product/product-v1-dc1a-default.yml --context $S1a

kubectl delete -f examples/applications/pcss-demo/search/search.yml --context $S2
kubectl apply -f examples/applications/pcss-demo/search/service-intentions-product.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product1a-resolver.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product-failover.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product-splitter.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product-retry.yml --context $S2

tfd -target module.consul-dc2-server -auto-approve
tfd -target module.consul-dc1-serverb -auto-approve
tfd -target module.consul-dc1-server -auto-approve

kubectl delete ns consul --context $S1a
kubectl delete ns consul --context $S1b
kubectl delete ns consul --context $S2
```