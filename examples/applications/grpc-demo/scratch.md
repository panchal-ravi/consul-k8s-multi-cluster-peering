k label ns default consul=enabled


k apply -f ./examples/applications/grpc-demo/proxy-defaults.yml --context $S1a

k apply -f ./examples/applications/grpc-demo/backend-az1.yml --context $S1a

k apply -f ./examples/applications/grpc-demo/backend-az2.yml --context $S1a

k apply -f ./examples/applications/grpc-demo/service-resolver-backend.yml --context $S1a

k apply -f ./examples/applications/grpc-demo/service-router-backend.yml --context $S1a

k apply -f ./examples/applications/grpc-demo/service-intentions-backend.yml --context $S1a

k apply -f ./examples/applications/grpc-demo/frontend.yml --context $S1a


while true; do k exec -i frontend-56c96d654d-kcbvd -c frontend -- curl -s -H "x-az:az2" localhost:9090 | jq ".upstream_calls[] | [.name, .ip_addresses[]] | @tsv" -r -r; sleep 1; done

kgp