/*
locals {
  key_pair_private_key = file("${var.local_privatekey_path}/${var.local_privatekey_filename}")
}

data "aws_ami" "an_image" {
  most_recent = true
  owners      = ["self"]
  filter {
    name   = "name"
    values = ["${var.owner}-secure-consul-*"]
  }
}

resource "aws_instance" "bastion" {
  ami             = data.aws_ami.an_image.id
  instance_type   = "t2.micro"
  key_name        = var.key_pair_key_name
  subnet_id       = element(module.vpc.public_subnets, 1)
  security_groups = [module.sg-ssh.security_group_id]

  lifecycle {
    ignore_changes = all
  }

  tags = {
    Name  = "${var.deployment_id}-bastion"
    owner = var.owner
    TTL   = var.ttl
  }

  connection {
    host        = aws_instance.bastion.public_ip
    user        = "ubuntu"
    agent       = false
    private_key = local.key_pair_private_key
  }

  provisioner "file" {
    source      = "${var.local_privatekey_path}/${var.local_privatekey_filename}"
    destination = "/home/ubuntu/${var.local_privatekey_filename}"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 400 /home/ubuntu/${var.local_privatekey_filename}",
    ]
  }
}

resource "aws_instance" "consul-server" {
  count                  = 2
  ami                    = data.aws_ami.an_image.id
  instance_type          = var.instance_type
  key_name               = var.key_pair_key_name
  subnet_id              = module.vpc.private_subnets[count.index]
  vpc_security_group_ids = [module.sg-consul.security_group_id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  tags = {
    Name             = "${var.deployment_id}-server-${count.index}"
    Instance         = "${var.deployment_id}-consul-server-${count.index}"
    owner            = var.owner
    consul-node-name = "server-${count.index}"
  }
}

resource "aws_iam_instance_profile" "instance_profile" {
  name_prefix = var.owner
  role        = aws_iam_role.instance_role.name
}

resource "aws_iam_role" "instance_role" {
  name_prefix        = var.owner
  assume_role_policy = data.aws_iam_policy_document.instance_role.json
  inline_policy {
    name   = "${var.deployment_id}-metadata-access"
    policy = data.aws_iam_policy_document.metadata_access.json
  }
}

data "aws_iam_policy_document" "instance_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "metadata_access" {
  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeInstances",
    ]
    resources = ["*"]
  }
}
*/
