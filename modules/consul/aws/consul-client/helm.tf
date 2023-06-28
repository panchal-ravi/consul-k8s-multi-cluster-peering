resource "local_file" "consul-client-helm-values" {
  content = templatefile("${path.root}/examples/templates/consul-client-helm.yml", {
    datacenter             = var.datacenter
    consul_version         = var.consul_version
    replicas               = var.replicas
    partition_name         = var.partition_name
    partition_service_fqdn = var.partition_service_fqdn
    cluster_api_endpoint   = var.cluster_api_endpoint
  })
  filename = "${path.module}/consul-client-helm-values-${var.partition_name}.yml.tmp"

  /*
  depends_on = [
    consul_admin_partition.partitions
  ]
  */
}

resource "helm_release" "consul-client" {
  name          = "${var.deployment_name}-consul-client"
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  version       = var.helm_chart_version
  namespace     = "consul"
  timeout       = "300"
  wait_for_jobs = true
  values = [
    local_file.consul-client-helm-values.content
  ]

  depends_on = [
    kubernetes_namespace.consul,
    kubernetes_secret.consul-ent-license
  ]
}
