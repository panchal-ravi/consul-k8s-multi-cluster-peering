/*
module "tgw" {
  source  = "terraform-aws-modules/transit-gateway/aws"
  version = "2.8.0"

  name = var.deployment_id

  enable_auto_accept_shared_attachments = true
  ram_allow_external_principals         = false

  vpc_attachments = {
    vpc1 = {
      vpc_id     = module.vpc["shared"].vpc_id
      subnet_ids = module.vpc["shared"].private_subnets
    },
    vpc2 = {
      vpc_id     = module.vpc["dev1"].vpc_id
      subnet_ids = module.vpc["dev1"].private_subnets
    }
  }
}

data "aws_route_table" "shared_private" {
  vpc_id = module.vpc["shared"].vpc_id
  tags = {
    Name = "${var.deployment_id}-shared-private"
  }
  depends_on = [
    module.vpc["shared"]
  ]
}

# Create a new route entry 
resource "aws_route" "shared_private_route" {
  route_table_id         = data.aws_route_table.shared_private.id
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id
  destination_cidr_block = module.vpc["dev1"].vpc_cidr_block
  depends_on = [
    module.vpc["dev1"]
  ]
}

data "aws_route_table" "dev1_private" {
  vpc_id = module.vpc["dev1"].vpc_id
  tags = {
    Name = "${var.deployment_id}-dev1-private"
  }
  depends_on = [
    module.vpc["dev1"]
  ]
}

# Create a new route entry 
resource "aws_route" "dev1_private_route" {
  route_table_id         = data.aws_route_table.dev1_private.id
  transit_gateway_id     = module.tgw.ec2_transit_gateway_id
  destination_cidr_block = module.vpc["shared"].vpc_cidr_block
  depends_on = [
    module.vpc["shared"]
  ]
}
*/