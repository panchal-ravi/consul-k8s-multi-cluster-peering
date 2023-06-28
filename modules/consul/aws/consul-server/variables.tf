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

variable "consul_k8s_version" {
  type = string
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

variable "datacenter" {
  type = string
}

/* variable "eks_cluster_suffix" {
  type = string
} */