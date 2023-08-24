locals {
  deployment_id             = lower("${var.deployment_name}-${random_string.suffix.result}")
  local_privatekey_path     = "${path.root}/private-key"
  local_privatekey_filename = "ssh-key.pem"
  consul_datacenters        = ["dc1a", "dc1b", "dc2"]
  eks_clusters = {
    "dc1-server" = {}
    /* "dc1-serverb"  = {} */
    /* "dc1-client1" = {} */
    /* "dc2-server"  = {} */
    /* dc2-client1" = {}  */
  }
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

resource "local_file" "consul-ent-license" {
  content  = var.consul_ent_license
  filename = "${path.root}/consul-ent-license.hclic"
}

module "infra-aws" {
  source = "./modules/infra/aws"

  region                             = var.aws_region
  owner                              = var.owner
  ttl                                = var.ttl
  deployment_id                      = local.deployment_id
  key_pair_key_name                  = var.aws_key_pair_key_name
  vpc_cidr                           = var.aws_vpc_cidr
  public_subnets                     = var.aws_public_subnets
  private_subnets                    = var.aws_private_subnets
  cluster_version                    = var.aws_eks_cluster_version
  cluster_service_cidr               = var.aws_eks_cluster_service_cidr
  self_managed_node_instance_type    = var.aws_eks_self_managed_node_instance_type
  self_managed_node_desired_capacity = var.aws_eks_self_managed_node_desired_capacity
  eks_clusters                       = local.eks_clusters
  local_privatekey_path              = local.local_privatekey_path
  local_privatekey_filename          = local.local_privatekey_filename
  consul_serf_lan_port               = var.consul_serf_lan_port
  ent_license                        = var.consul_ent_license
  instance_type                      = var.aws_instance_type
}

module "consul-dc1-server" {
  source = "./modules/consul/aws/consul-server"
  providers = {
    kubernetes = kubernetes.dc1-server,
    helm       = helm.dc1-server
  }

  deployment_name    = var.deployment_name
  datacenter         = local.consul_datacenters[0]
  helm_chart_version = var.consul_helm_chart_version
  consul_version     = var.consul_version
  consul_k8s_version = var.consul_k8s_version
  ent_license        = var.consul_ent_license
  replicas           = var.consul_replicas
  serf_lan_port      = var.consul_serf_lan_port
  /* eks_cluster_suffix = "dc1-server" */

  depends_on = [
    module.infra-aws
  ]
}

module "consul-dc1-serverb" {
  source = "./modules/consul/aws/consul-server"
  providers = {
    kubernetes = kubernetes.dc1-serverb,
    helm       = helm.dc1-serverb
  }

  deployment_name    = var.deployment_name
  datacenter         = local.consul_datacenters[1]
  helm_chart_version = var.consul_helm_chart_version
  consul_version     = var.consul_version
  consul_k8s_version = var.consul_k8s_version
  ent_license        = var.consul_ent_license
  replicas           = var.consul_replicas
  serf_lan_port      = var.consul_serf_lan_port
  /* eks_cluster_suffix = "dc1-server" */

  depends_on = [
    module.infra-aws
  ]
}

module "consul-dc2-server" {
  source = "./modules/consul/aws/consul-server"
  providers = {
    kubernetes = kubernetes.dc2-server,
    helm       = helm.dc2-server
  }

  deployment_name    = var.deployment_name
  datacenter         = local.consul_datacenters[2]
  helm_chart_version = var.consul_helm_chart_version
  consul_version     = var.consul_version
  consul_k8s_version = var.consul_k8s_version
  ent_license        = var.consul_ent_license
  replicas           = var.consul_replicas
  serf_lan_port      = var.consul_serf_lan_port
  /* eks_cluster_suffix = "dc2-server" */

  depends_on = [
    module.infra-aws
  ]
}

module "consul-dc1-client1" {
  source = "./modules/consul/aws/consul-client"
  providers = {
    kubernetes = kubernetes.dc1-client1,
    helm       = helm.dc1-client1
  }

  deployment_name    = var.deployment_name
  helm_chart_version = var.consul_helm_chart_version
  consul_version     = var.consul_version
  ent_license        = var.consul_ent_license
  replicas           = var.consul_replicas
  serf_lan_port      = var.consul_serf_lan_port
  datacenter         = local.consul_datacenters[0]
  partition_name     = "default"
  /* partition_name              = "hr" */
  partition_service_fqdn      = module.consul-dc1-server.partition_public_fqdn
  cluster_api_endpoint        = data.aws_eks_cluster.dc1-client1.endpoint
  ca-cert                     = module.consul-dc1-server.ca-cert
  ca-key                      = module.consul-dc1-server.ca-key
  consul_partitions_acl_token = module.consul-dc1-server.consul_partitions_acl_token
  /* eks_cluster_suffix          = "dc1-client1" */

  depends_on = [
    module.consul-dc1-server
  ]
}

module "consul-dc2-client1" {
  source = "./modules/consul/aws/consul-client"
  providers = {
    kubernetes = kubernetes.dc2-client1,
    helm       = helm.dc2-client1
  }

  deployment_name             = var.deployment_name
  helm_chart_version          = var.consul_helm_chart_version
  consul_version              = var.consul_version
  ent_license                 = var.consul_ent_license
  replicas                    = var.consul_replicas
  serf_lan_port               = var.consul_serf_lan_port
  datacenter                  = local.consul_datacenters[1]
  partition_name              = "finance"
  partition_service_fqdn      = module.consul-dc2-server.partition_public_fqdn
  cluster_api_endpoint        = data.aws_eks_cluster.dc2-client1.endpoint
  ca-cert                     = module.consul-dc2-server.ca-cert
  ca-key                      = module.consul-dc2-server.ca-key
  consul_partitions_acl_token = module.consul-dc2-server.consul_partitions_acl_token
  /* eks_cluster_suffix          = "dc2-client1" */

  depends_on = [
    module.consul-dc2-server
  ]
}

module "consul-acl" {
  source = "./modules/consul/aws/consul-acl"
  providers = {
    consul = consul.dc1-server
  }
  datacenter   = local.consul_datacenters[0]
  consul_token = module.consul-dc1-server.consul-bootstrap-acl-token.token
  consul_addr  = module.consul-dc1-server.ui_public_fqdn
  depends_on   = [module.consul-dc1-server]
}
