## Create EKS fargate cluster

```
export VPC_ID=$(aws ec2 describe-vpcs --region=ap-southeast-1 | jq '.[][] | select(.IsDefault == false) | .VpcId' -r)
export DEPLOYMENT_ID=$(tfo -raw deployment_id)
export CLUSTER_NAME=$DEPLOYMENT_ID-dc1-client1
export REGION=ap-southeast-1
export SUBNETS=$(aws ec2 describe-subnets --filters Name=vpc-id,Values=$VPC_ID --region $REGION | jq -r '.Subnets[] | select(.MapPublicIpOnLaunch == false) | .SubnetId' | xargs | sed -e "s/ /,/g")

eksctl create cluster \
    --name $CLUSTER_NAME \
    --region $REGION \
    --fargate \
    --vpc-private-subnets $SUBNETS \
    --version 1.22
```

## Setup AWS LoadBalancer Controller
Reference: https://aws.amazon.com/premiumsupport/knowledge-center/eks-alb-ingress-controller-fargate/

```
eksctl utils associate-iam-oidc-provider --cluster $CLUSTER_NAME --region $REGION --approve

aws iam create-policy \
   --policy-name AWSLoadBalancerControllerIAMPolicy \
   --policy-document file://./files/eks_fargate/iam_policy.json

eksctl create iamserviceaccount \
  --cluster=$CLUSTER_NAME \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --attach-policy-arn=arn:aws:iam::475368203962:policy/AWSLoadBalancerControllerIAMPolicy \
  --override-existing-serviceaccounts \
  --region $REGION \
  --approve

kubectl get serviceaccount aws-load-balancer-controller --namespace kube-system

helm repo add eks https://aws.github.io/eks-charts

kubectl apply -k "github.com/aws/eks-charts/stable/aws-load-balancer-controller//crds?ref=master"

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
    --set clusterName=$CLUSTER_NAME \
    --set serviceAccount.create=false \
    --set region=$REGION \
    --set vpcId=$VPC_ID \
    --set serviceAccount.name=aws-load-balancer-controller \
    -n kube-system
```

## Test cluster with nginx
```
 kubectl apply -f files/eks_fargate/nginx-deployment.yaml
 kubectl apply -f files/eks_fargate/nginx-service.yaml

 kubectl delete -f files/eks_fargate/nginx-deployment.yaml
 kubectl delete -f files/eks_fargate/nginx-service.yaml
 
 ```

## Install Consul in client partition --
```
eksctl create fargateprofile --cluster $CLUSTER_NAME \
    --name fp-consul \
    --region $REGION \
    --namespace consul

export SERVER=$(kubectl config get-contexts -oname | grep -i server)

export CLIENT=$(kubectl config get-contexts -oname | grep -i client)

kubectl --context $CLIENT create ns consul

kubectl --context $CLIENT \
  create --namespace consul secret generic license \
  --from-literal=key=$(cat ./files/eks_fargate/license.hclic | tr -d '\n')

kubectl --context $SERVER get secret --namespace consul consul-ca-cert -o yaml | \
    kubectl --context $CLIENT apply --namespace consul -f -

kubectl --context $SERVER get secret --namespace consul consul-ca-key -o yaml | \
    kubectl --context $CLIENT apply --namespace consul -f -

kubectl --context $SERVER get secret --namespace consul consul-partitions-acl-token -o yaml | \
    kubectl --context $CLIENT apply --namespace consul -f -

## Retrieve Consul external-server address and update consul-client-helm.yaml
kgs -n consul consul-expose-servers --context $SERVER -ojson | jq ".status.loadBalancer.ingress[].hostname" -r

## Update k8sAuthMethoHost with the cluster URL in consul-client-helm.yaml

## EKS Fargate requires aws load balancer with below annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"

helm install consul -f ./files/eks_fargate/consul-client-helm.yml \
  hashicorp/consul --namespace consul --version v1.0.1 --kube-context $CLIENT
```

## Test Consul service-mesh with Ingress Gateway
 kubectl apply -f files/eks_fargate/backend-v1-local.yml
 kubectl apply -f files/eks_fargate/frontend.yml
 kubectl apply -f files/eks_fargate/service-intentions.yml
 kubectl apply -f files/eks_fargate/ingress-gateway.yml


 kubectl delete -f files/eks_fargate/backend-v1-local.yml
 kubectl delete -f files/eks_fargate/frontend.yml
 kubectl delete -f files/eks_fargate/ingress-gateway.yml
 kubectl delete -f files/eks_fargate/service-intentions.yml

## Delete fargate cluster
```
eksctl delete cluster -n $CLUSTER_NAME --region $REGION
```