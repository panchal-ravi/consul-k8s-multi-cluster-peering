data "aws_caller_identity" "current" {}
/*
resource "aws_iam_role" "load-balancer-role" {
  for_each = var.eks_clusters
  name     = "AmazonEKSLoadBalancerControllerRole_${each.key}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${split("/", module.eks[each.key].oidc_provider)[2]}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks[each.key].oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks[each.key].oidc_provider}:sub" : "system:serviceaccount:kube-system:aws-load-balancer-controller"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "load_balancer_role_attach" {
  for_each   = var.eks_clusters
  role       = aws_iam_role.load-balancer-role[each.key].name
  policy_arn = "arn:aws:iam::475368203962:policy/AWSLoadBalancerControllerIAMPolicy"
}
*/

resource "aws_iam_role" "ebs-csi-role" {
  for_each = var.eks_clusters
  name     = "AmazonEKS_EBS_CSI_DriverRole_${each.key}"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "Federated" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/oidc.eks.${var.region}.amazonaws.com/id/${split("/", module.eks[each.key].oidc_provider)[2]}"
        },
        "Action" : "sts:AssumeRoleWithWebIdentity",
        "Condition" : {
          "StringEquals" : {
            "${module.eks[each.key].oidc_provider}:aud" : "sts.amazonaws.com",
            "${module.eks[each.key].oidc_provider}:sub" : "system:serviceaccount:kube-system:ebs-csi-controller-sa"
          }
        }
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ebs_csi_role_attach" {
  for_each   = var.eks_clusters
  role       = aws_iam_role.ebs-csi-role[each.key].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
