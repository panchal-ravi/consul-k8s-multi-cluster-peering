#!/bin/bash
kubectl exec -i $1 -- curl localhost:19000/config_dump\?include_eds > /tmp/config