## Configure cluster peering traffic routing
- Apply ```peer-through-meshgateways.yaml``` to configure control-plane traffic routing via mesh gateway. 
This should be applied in the default partition of all Consul Datacenters you want to peer where Consul servers are running.
```
kubectl apply -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S1a
kubectl apply -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S1b
kubectl apply -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S2
```

## Configure cluster peering traffic 
- Apply ```originate-via-meshgateways.yaml``` file to all default partitions. 
```
kubectl apply -f examples/cluster-peering-yamls-default/originate-via-meshgateways.yaml --context $S1a
kubectl apply -f examples/cluster-peering-yamls-default/originate-via-meshgateways.yaml --context $S1b
kubectl apply -f examples/cluster-peering-yamls-default/originate-via-meshgateways.yaml --context $S2
```
This is to route traffic from local services to remote services via mesh gateways.


## Setup cluster peering between dc1a and dc2
```
kubectl apply -f examples/cluster-peering-yamls-default/acceptor-on-dc1a-for-dc2.yaml --context $S1a
kubectl get secrets peering-token-dc1a-default-dc2-default --context $S1a -oyaml | kubectl apply -f - --context $S2
kubectl apply -f examples/cluster-peering-yamls-default/dialer-dc2-to-dc1a.yaml --context $S2

# Verify that the two Consul clusters are peered.
source ./scripts/s1a.sh
curl -s -H "Authorization: Bearer $CONSUL_HTTP_TOKEN" -k $CONSUL_HTTP_ADDR/v1/peering/dc2-default\?partition=default | jq .
```

## Setup cluster peering between dc1b and dc2
```
kubectl apply -f examples/cluster-peering-yamls-default/acceptor-on-dc1b-for-dc2.yaml --context $S1b
kubectl get secrets peering-token-dc1b-default-dc2-default --context $S1b -oyaml | kubectl apply -f - --context $S2
kubectl apply -f examples/cluster-peering-yamls-default/dialer-dc2-to-dc1b.yaml --context $S2

# Verify that the two Consul clusters are peered.
source ./scripts/s1b.sh
curl -s -H "Authorization: Bearer $CONSUL_HTTP_TOKEN" -k $CONSUL_HTTP_ADDR/v1/peering/dc2-default\?partition=default | jq .
```

## Delete peering relationships
```
kubectl delete -f examples/cluster-peering-yamls-default/acceptor-on-dc1a-for-dc2.yaml --context $S1a
kubectl delete -f examples/cluster-peering-yamls-default/acceptor-on-dc1b-for-dc2.yaml --context $S1b
kubectl delete -f examples/cluster-peering-yamls-default/dialer-dc2-to-dc1a.yaml --context $S2
kubectl delete -f examples/cluster-peering-yamls-default/dialer-dc2-to-dc1b.yaml --context $S2

kubectl delete secrets peering-token-dc1a-default-dc2-default --context $S1a
kubectl delete secrets peering-token-dc1b-default-dc2-default --context $S1b
kubectl delete secrets peering-token-dc1a-default-dc2-default --context $S2
kubectl delete secrets peering-token-dc1b-default-dc2-default --context $S2

kubectl delete -f examples/cluster-peering-yamls-default/originate-via-meshgateways.yaml --context $S1a
kubectl delete -f examples/cluster-peering-yamls-default/originate-via-meshgateways.yaml --context $S1b
kubectl delete -f examples/cluster-peering-yamls-default/originate-via-meshgateways.yaml --context $S2

kubectl delete -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S1a
kubectl delete -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S1b
kubectl delete -f examples/cluster-peering-yamls-default/peer-through-meshgateways.yaml --context $S2
```