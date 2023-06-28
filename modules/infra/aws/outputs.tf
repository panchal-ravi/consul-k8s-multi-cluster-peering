output "vpc_public_subnet_id" {
  value = module.vpc.public_subnets
}

output "sg_ssh_id" {
  value = module.sg-ssh.security_group_id
}

output "sg_consul_id" {
  value = module.sg-consul.security_group_id
}

output "eks_cluster_ids" {
  value = { for k, v in module.eks : k => v.cluster_id }
}

output "eks_cluster_api_endpoints" {
  value = { for k, v in module.eks : k => v.cluster_endpoint }
}

output "cluster_oidc_issuer_url" {
  value = { for k, v in module.eks: k => v.cluster_oidc_issuer_url}
}

/*
output "bastion_ip" {
  value = aws_instance.bastion.public_ip
}


output "eks_dc1_server_cluster_id" {
  value = module.eks
}

output "eks_dc1_server_cluster_api_endpoint" {
  value = module.eks-dc1-server.cluster_endpoint
}


output "eks_dc1_client_cluster_id" {
  value = module.eks-dc1-client.cluster_id
}

output "eks_dc1_client_cluster_api_endpoint" {
  value = module.eks-dc1-client.cluster_endpoint
}

output "bastion_ip" {
  description = "Public IP of bastion"
  value       = aws_instance.bastion.public_ip
}
*/