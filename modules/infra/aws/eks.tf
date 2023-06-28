module "eks" {
  source                          = "terraform-aws-modules/eks/aws"
  for_each                        = var.eks_clusters
  version                         = "18.26.3"
  cluster_name                    = "${var.deployment_id}-${each.key}"
  cluster_version                 = var.cluster_version
  vpc_id                          = module.vpc.vpc_id
  subnet_ids                      = module.vpc.private_subnets
  cluster_endpoint_private_access = true
  cluster_service_ipv4_cidr       = var.cluster_service_cidr

  eks_managed_node_group_defaults = {
  }

  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
      service_account_role_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKS_EBS_CSI_DriverRole_${each.key}"
    }
  }

  cluster_security_group_additional_rules = {
    ops_private_access_egress = {
      description = "Ops Private Egress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "egress"
      cidr_blocks = ["10.200.0.0/16"]
    }
    ops_private_access_ingress = {
      description = "Ops Private Ingress"
      protocol    = "-1"
      from_port   = 0
      to_port     = 0
      type        = "ingress"
      cidr_blocks = ["10.200.0.0/16"]
    }
  }


  eks_managed_node_groups = {
    "${each.key}" = {
      min_size               = 1
      max_size               = 3
      desired_size           = var.self_managed_node_desired_capacity
      instance_types         = [var.self_managed_node_instance_type]
      key_name               = var.key_pair_key_name
      vpc_security_group_ids = [module.sg-consul.security_group_id, module.sg-ssh.security_group_id]
    }
  }

  tags = {
    owner = var.owner
    TTL   = var.ttl
  }
}


resource "null_resource" "kubeconfig" {

  provisioner "local-exec" {
    command = <<-EOT
      %{for key,value in var.eks_clusters ~}
      aws eks --region ${var.region} update-kubeconfig --kubeconfig ${path.root}/${var.deployment_id}-kubeconfig --name ${module.eks[key].cluster_id};
      %{endfor}
      EOT
  }

  depends_on = [
    module.eks
  ]
}
