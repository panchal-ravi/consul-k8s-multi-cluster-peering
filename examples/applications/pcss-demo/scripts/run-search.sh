while true; do kubectl exec -i $(kubectl get pod -l app=search -oname) -c search -- curl -s localhost:9090 | jq '.upstream_calls[] | "\(.name), \(.code)"' -r; sleep 1; done
