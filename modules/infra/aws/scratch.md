eksctl create iamserviceaccount \
  --cluster=rp-cpeer-rzxrtgg0-dc1-server \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole_dc1_server \
  --attach-policy-arn=arn:aws:iam::475368203962:policy/AWSLoadBalancerControllerIAMPolicy \
  --region ap-southeast-1 \
  --approve

eksctl create iamserviceaccount \
  --cluster=rp-cpeer-ogki5jne-dc2-server \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole_dc2_server \
  --attach-policy-arn=arn:aws:iam::475368203962:policy/AWSLoadBalancerControllerIAMPolicy \
  --region ap-southeast-1 \
  --approve

eksctl create iamserviceaccount \
  --cluster=rp-cpeer-ogki5jne-dc1-client1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole_dc1_client1 \
  --attach-policy-arn=arn:aws:iam::475368203962:policy/AWSLoadBalancerControllerIAMPolicy \
  --region ap-southeast-1 \
  --approve

eksctl create iamserviceaccount \
  --cluster=rp-cpeer-ogki5jne-dc2-client1 \
  --namespace=kube-system \
  --name=aws-load-balancer-controller \
  --role-name AmazonEKSLoadBalancerControllerRole_dc2_client1 \
  --attach-policy-arn=arn:aws:iam::475368203962:policy/AWSLoadBalancerControllerIAMPolicy \
  --region ap-southeast-1 \
  --approve

helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=rp-cpeer-rzxrtgg0-dc1-server \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=rp-cpeer-ogki5jne-dc2-server \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=rp-cpeer-ogki5jne-dc1-client1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=rp-cpeer-ogki5jne-dc2-client1 \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller 