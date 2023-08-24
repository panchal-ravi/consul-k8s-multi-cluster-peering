#!/bin/bash
kubectl exec -i $1 -- curl -X POST localhost:19000/logging\?level=debug