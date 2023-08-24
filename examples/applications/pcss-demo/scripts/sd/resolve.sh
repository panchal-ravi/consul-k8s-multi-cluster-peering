kubectl -n utils exec -i $(kubectl get po -n utils -o name) -- dig @$(kubectl get svc -n consul consul-dns -ojson | jq .spec.clusterIP -r) frontend.service.consul +short
