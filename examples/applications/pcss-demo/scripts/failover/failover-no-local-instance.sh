kubectl scale deployment product-v1 --replicas 0 --context $S2

kubectl apply -f /Users/ravipanchal/learn/terraform/terraform-consul-k8s-peering-admin-partitions/examples/applications/pcss-demo/search/product-failover.yml --context $S2
