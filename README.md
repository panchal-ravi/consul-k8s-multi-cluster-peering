### Setup peering relationship
Refer ./examples/cluster-peering-yamls-default/peering.md

### Deploy applications and test failover across cluster peering
Refer ./examples/cluster-peering-yamls-default/scratch.md

### Deploy applications and test SamenessGroup feature
Refer ./examples/cluster-peering-yamls-default/sd-sameness.md


### General Notes

Create EKS fargate cluster

eksctl create cluster \
    --name rp-cpeer-ogki5jne-dc1-client \
    --region ap-southeast-1 \
    --fargate \
    --vpc-private-subnets subnet-0311ac7b4cfc96db7,subnet-07aa650cb6a7babbd,subnet-002a1c08508db61b5 \
    --version 1.22

### Create IAM user in hashicorp account
aws iam create-user --user-name demo-ravi.panchal@hashicorp.com --permissions-boundary arn:aws:iam::475368203962:policy/DemoUser

