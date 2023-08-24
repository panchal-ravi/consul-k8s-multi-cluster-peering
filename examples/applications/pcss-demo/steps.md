cd /Users/ravipanchal/learn/terraform/terraform-consul-k8s-peering-admin-partitions/examples/applications/pcss-demo

## Service Registry Demo

### Deploy frontend
./scripts/sd/deploy-frontend.sh

### Resolve frontend
./scripts/sd/resolve.sh

### Deploy frontend-v2
./scripts/sd/deploy-frontend-v2.sh

### Resolve frontend
./scripts/sd/resolve.sh

### Deploy frontend-v2-failing
./scripts/sd/deploy-frontend-v2-failing.sh

### Resolve frontend
./scripts/sd/resolve.sh

### Reset 
./scripts/sd/reset.sh


---------------------------------------------------------------------------------------------------
## Security Demo

### Reset configurations
./scripts/reset.sh

### Deny access
./scripts/security/deny-access.sh

### Run Search
./scripts/run-search.sh

### Allow access
./scripts/security/allow-access.sh

### Run Search
./scripts/run-search.sh

---------------------------------------------------------------------------------------------------
## Failover Demo

### Reset configurations
./scripts/reset.sh

### Run Search
./scripts/run-search.sh

### Kill all instances of product service in local datacenter 
./scripts/failover/failover-no-local-instance.sh

### Run Search
./scripts/run-search.sh

### Deploy failing product service in local datacenter 
./scripts/failover/failover-failing-local-instance.sh

### Run Search
./scripts/run-search.sh

---------------------------------------------------------------------------------------------------
## Traffic-Split Demo across sites/clusters

### Reset configurations
./scripts/reset.sh

### Run Search
./scripts/run-search.sh

### Apply traffic-split
./scripts/traffic-split/active-active.sh

### Run Search
./scripts/run-search.sh

### Kill all instances of product service in local datacenter 
./scripts/failover/failover-no-local-instance.sh

### Run Search
./scripts/run-search.sh
