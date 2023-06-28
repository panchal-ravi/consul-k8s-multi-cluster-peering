## Configure cluster peering traffic routing
- Apply ```peer-through-meshgateways.yaml``` to configure control-plane traffic routing via mesh gateway. 
This should be applied in the default partition of all Consul Datacenters you want to peer where Consul servers are running.
```
kubectl apply -f examples/cluster-peering-yamls/peer-through-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-server

kubectl apply -f examples/cluster-peering-yamls/peer-through-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server
```

## Configure cluster peering traffic 
- Apply ```originate-via-meshgateways.yaml``` file to all client partitions. 
```
kubectl apply -f examples/cluster-peering-yamls/originate-via-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl apply -f examples/cluster-peering-yamls/originate-via-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```
This is to route traffic from local services to remote services via mesh gateways.

## Apply PeeringAcceptor
- Apply ```accepton-on-dc1-for-dc2.yaml``` to hr partition in dc1 datacenter.
```
kubectl apply -f examples/cluster-peering-yamls/acceptor-on-dc1-for-dc2.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1
```
- This shoudCreate a peering token

## Import the token into finance partition in dc2 datacenter
```
kubectl get secrets peering-token-dc1-hr-dc2-finance --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1 -oyaml | kubectl apply -f - --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

## Apply PeeringDialer
- Configuring a peering dialer role for a cluster makes an outbound peering connection towards a peering acceptor cluster using the specified peering token. 
- Apply ```dialer-dc2.yaml``` to finance partition in dc2 datacenter
```
kubectl apply -f examples/cluster-peering-yamls/dialer-dc2.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

## Verify that the two Consul clusters are peered.
```
curl -s -H "Authorization: Bearer $CONSUL_HTTP_TOKEN" -k $CONSUL_HTTP_ADDR/v1/peering/dc2-finance\?partition=hr | jq .
```

## Deploy backend app in "finance" partition in dc2 datacenter
- Apply ```backend-v1-dc2-finance.yml```
```
kubectl apply -f examples/applications/multi-peers/backend/backend-v1-dc2-finance.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

- Export service to ```dc1-hr``` peer. Apply ```export-service-backend.yml```.
```
kubectl apply -f examples/applications/multi-peers/backend/export-service-backend.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```
- Configure service-intention to allow traffic from frontend. Apply ```service-intentions.yaml```.
```
kubectl apply -f examples/applications/multi-peers/backend/service-intentions.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```

## Deploy frontend app in "hr" partition in dc1 datacenter
- Apply ```frontend.yml```
```
kubectl apply -f examples/applications/multi-peers/frontend/frontend.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1
```
- Apply ```ingress-gateways.yml```
```
kubectl apply -f examples/applications/multi-peers/frontend/ingress-gateway.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1 
```
- Apply ```service-intentions.yml```
```
kubectl apply -f examples/applications/multi-peers/frontend/service-intentions.yml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1  
```

## Test application
```
curl http://$(kubectl get svc -n consul -l component=ingress-gateway --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1  -ojson  | jq ".items[].status.loadBalancer.ingress[].hostname" -r)
```

## Delete services and configuration
```
kubectl delete -f examples/applications/multi-peers/frontend --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl delete -f examples/applications/multi-peers/backend --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete -f examples/cluster-peering-yamls/originate-via-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl delete -f examples/cluster-peering-yamls/originate-via-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete -f examples/cluster-peering-yamls/acceptor-on-dc1-for-dc2.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl delete -f examples/cluster-peering-yamls/dialer-dc2.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete secrets peering-token-dc1-hr-dc2-finance  --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl delete secrets peering-token-dc1-hr-dc2-finance  --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

kubectl delete -f examples/cluster-peering-yamls/peer-through-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-server

kubectl delete -f examples/cluster-peering-yamls/peer-through-meshgateways.yaml --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server

helm uninstall -n consul rp-cpeer-consul-client --kube-context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1

helm uninstall -n consul rp-cpeer-consul-client --kube-context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

helm uninstall -n consul rp-cpeer-consul-server --kube-context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-server

helm uninstall -n consul rp-cpeer-consul-server --kube-context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server

kubectl delete ns consul --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-server

kubectl delete ns consul --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-server

kubectl delete ns consul --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc1-client1

kubectl delete ns consul --context arn:aws:eks:ap-southeast-1:475368203962:cluster/rp-cpeer-ogki5jne-dc2-client1
```