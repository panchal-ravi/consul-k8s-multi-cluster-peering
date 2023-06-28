resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
}

resource "kubernetes_secret" "consul-ca-cert" {
  metadata {
    name      = "consul-ca-cert"
    namespace = "consul"
  }

  data = var.ca-cert
}

resource "kubernetes_secret" "consul-ca-key" {
  metadata {
    name      = "consul-ca-key"
    namespace = "consul"
  }

  data = var.ca-key
}

resource "kubernetes_secret" "consul-partitions-acl-token" {
  metadata {
    name      = "consul-partitions-acl-token"
    namespace = "consul"
  }

  data = var.consul_partitions_acl_token
}

resource "kubernetes_secret" "consul-ent-license" {
  metadata {
    name      = "consul-ent-license"
    namespace = "consul"
  }

  data = {
    key = var.ent_license
  }
}
