# terraform-consul-admin-partitions-telkomsel

## How to use this module

### Post deployment
#### TODO list

Create EKS fargate cluster

eksctl create cluster \
    --name rp-cpeer-ogki5jne-dc1-client \
    --region ap-southeast-1 \
    --fargate \
    --vpc-private-subnets subnet-0311ac7b4cfc96db7,subnet-07aa650cb6a7babbd,subnet-002a1c08508db61b5 \
    --version 1.22