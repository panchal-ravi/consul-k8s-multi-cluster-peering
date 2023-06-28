## Create IAM Role
Ref: https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html

export REGION=ap-southeast-1
export CLUSTER=rp-cpeer-ogki5jne-dc1-server

aws eks describe-cluster \
  --region $REGION \
  --name $CLUSTER \
  --query "cluster.identity.oidc.issuer" \
  --output text

## Update trust-policy.json 
aws iam create-role \
  --role-name AmazonEKS_EBS_CSI_DriverRole \
  --assume-role-policy-document file://"./files/k8s/aws-ebs-csi-driver-trust-policy.json"

aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --role-name AmazonEKS_EBS_CSI_DriverRole

kubectl annotate serviceaccount ebs-csi-controller-sa \
    -n kube-system \
    eks.amazonaws.com/role-arn=arn:aws:iam::475368203962:role/AmazonEKS_EBS_CSI_DriverRole
