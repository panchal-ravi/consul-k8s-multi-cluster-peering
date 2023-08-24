kubectl delete -f examples/applications/pcss-demo/search/service-intentions-product.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product1a-resolver.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product-failover.yml --context $S2
kubectl delete -f examples/applications/pcss-demo/search/product-splitter.yml --context $S2

