/* data "aws_caller_identity" "current" {} */

data "kubernetes_service" "consul-ui" {
  metadata {
    name      = "consul-ui"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_service" "consul-partition" {
  metadata {
    name      = "consul-expose-servers"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_pod" "consul-server" {
  metadata {
    name      = "consul-server-0"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_secret" "consul-ca-cert" {
  metadata {
    name      = "consul-ca-cert"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_secret" "consul-ca-key" {
  metadata {
    name      = "consul-ca-key"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_secret" "consul-partitions-acl-token" {
  metadata {
    name      = "consul-partitions-acl-token"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

data "kubernetes_secret" "consul-bootstrap-acl-token" {
  metadata {
    name      = "consul-bootstrap-acl-token"
    namespace = "consul"
  }

  depends_on = [
    helm_release.consul-server
  ]
}

resource "kubernetes_namespace" "consul" {
  metadata {
    name = "consul"
  }
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

resource "kubernetes_storage_class_v1" "gp2-immediate" {
  metadata {
    name = "gp2-immediate"
  }
  storage_provisioner = "kubernetes.io/aws-ebs"
  reclaim_policy      = "Delete"
  volume_binding_mode = "Immediate"
  parameters = {
    fsType = "ext4"
    type = "gp2"
  }
}

/* resource "kubernetes_annotations" "ebs-csi-controller-sa" {
  api_version = "v1"
  kind        = "ServiceAccount"
  metadata {
    name = "ebs-csi-controller-sa"
    namespace = "kube-system"
  }
  annotations = {
    "eks.amazonaws.com/role-arn" = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/AmazonEKS_EBS_CSI_DriverRole_${var.eks_cluster_suffix}"
  }
} */
