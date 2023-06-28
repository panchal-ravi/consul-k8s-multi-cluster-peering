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

## Deploy backend app in "default" partition in dc2 datacenter 
```
kubectl label ns default consul=enabled --context $S2
kubectl apply -f examples/applications/multi-peers-default/backend/backend-v1-dc2-default.yml --context $S2
```

## Apply samenessgroup
```
kubectl apply -f examples/applications/multi-peers-default/sd/sameness-group.yml --context $S2
```

## Create PreparedQuery
```
source ./scripts/s2.sh
curl -s -k -X POST -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query \
    --data @examples/applications/multi-peers-default/sd/prepared-query.json
```
## Execute PreparedQuery
```
source ./scripts/s2.sh
export QUERY_ID=$(curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query | jq ".[].ID" -r)
curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query/$QUERY_ID/execute | jq .
```

## Demo
```
source ./scripts/s2.sh
export QUERY_ID=$(curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query | jq ".[].ID" -r)

# Remove backend service instance in local partition
kubectl scale deploy backend-v1 --replicas 0 --context $S2
curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query/$QUERY_ID/execute | jq .

# Remove backend service instance in dc1a-default peer
kubectl scale deploy backend-v1 --replicas 0 --context $S1a
curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query/$QUERY_ID/execute | jq .
```

## Delete PreparedQuery
```
source ./scripts/s2.sh
export QUERY_ID=$(curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/query | jq ".[].ID" -r)
curl -s -k -H "X-Consul-Token: $CONSUL_HTTP_TOKEN" -X DELETE $CONSUL_HTTP_ADDR/v1/query/$QUERY_ID
```