resource "local_file" "consul-server-helm-values" {
  content = templatefile("${path.root}/examples/templates/consul-server-helm.yml", {
    datacenter     = var.datacenter
    consul_version = var.consul_version
    /* consul_k8s_version = var.consul_k8s_version */
    replicas      = var.replicas
    serf_lan_port = var.serf_lan_port
  })
  filename = "${path.module}/consul-server-helm-values-${var.datacenter}.yml.tmp"
}

resource "helm_release" "consul-server" {
  name          = "${var.deployment_name}-consul-server"
  chart         = "consul"
  repository    = "https://helm.releases.hashicorp.com"
  /* version       = var.helm_chart_version */
  devel         = true
  namespace     = "consul"
  timeout       = "300"
  wait_for_jobs = true
  values = [
    local_file.consul-server-helm-values.content
  ]

  depends_on = [
    kubernetes_namespace.consul,
    kubernetes_secret.consul-ent-license,
    kubernetes_storage_class_v1.gp2-immediate
  ]
}
