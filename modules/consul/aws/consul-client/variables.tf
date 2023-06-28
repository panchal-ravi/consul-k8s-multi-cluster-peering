variable "deployment_name" {
  description = "Deployment name, used to prefix resources"
  type        = string
}

variable "helm_chart_version" {
  type        = string
  description = "Helm chart version"
}

variable "consul_version" {
  description = "Consul version"
  type        = string
}

variable "ent_license" {
  description = "Consul enterprise license"
  type        = string
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
}

variable "serf_lan_port" {
  description = "Consul serf lan port"
  type        = number
}

variable "partition_service_fqdn" {
  description = "Consul partition service fqdn"
  type        = string
}

variable "cluster_api_endpoint" {
  description = "Address of the kubernetes api server"
  type        = string
}

variable "ca-cert" {
  description = "Conaul server ca certificate"
}

variable "ca-key" {
  description = "Conaul server ca key"
}

variable "consul_partitions_acl_token" {
  description = "Consul server partitions ACL token"
}
variable "datacenter" {
  type = string
}

variable "partition_name" {
}

/* variable "eks_cluster_suffix" {
  type = string
} */