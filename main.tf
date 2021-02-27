locals {
  nat_gateway_count = length(var.private_subnets)
}
#################
# VPC RESOURCES #
#################
resource "aws_vpc" "this" {
  cidr_block                       = var.cidr
  instance_tenancy                 = var.instance_tenancy
  enable_dns_hostnames             = var.enable_dns_hostnames
  enable_dns_support               = var.enable_dns_support
  enable_classiclink               = var.enable_classiclink
  enable_classiclink_dns_support   = var.enable_classiclink_dns_support
  assign_generated_ipv6_cidr_block = var.enable_ipv6

  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.vpc_tags,
  )
}

###########################
# PUBLIC SUBNET RESOURCES #
###########################
resource "aws_subnet" "public_subnet" {
  count                           = length(var.public_subnets) > 0 && (length(var.public_subnets) >= length(var.availability_zones)) ? length(var.public_subnets) : 0
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = element(concat(var.public_subnets, [""]), count.index)
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.availability_zones, count.index))) > 0 ? element(var.availability_zones, count.index) : null
  map_public_ip_on_launch         = var.map_public_ip_on_launch
  assign_ipv6_address_on_creation = var.public_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.public_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.public_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, var.public_subnet_ipv6_prefixes[count.index]) : null
  # Merge all tags
  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_suffix}-%s",
        var.name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
    var.public_subnet_tags,
  )

  depends_on = [aws_vpc.this]
}

############################
# PRIVATE SUBNET RESOURCES #
############################
resource "aws_subnet" "private_subnet" {
  count                           = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0
  vpc_id                          = aws_vpc.this.id
  cidr_block                      = var.private_subnets[count.index]
  availability_zone               = length(regexall("^[a-z]{2}-", element(var.availability_zones, count.index))) > 0 ? element(var.availability_zones, count.index) : null
  assign_ipv6_address_on_creation = var.private_subnet_assign_ipv6_address_on_creation == null ? var.assign_ipv6_address_on_creation : var.private_subnet_assign_ipv6_address_on_creation
  ipv6_cidr_block                 = var.enable_ipv6 && length(var.private_subnet_ipv6_prefixes) > 0 ? cidrsubnet(aws_vpc.this.ipv6_cidr_block, 8, var.private_subnet_ipv6_prefixes[count.index]) : null
  # Merge all tags
  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_suffix}-%s",
        var.name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
    var.private_subnet_tags,
  )

  depends_on = [aws_vpc.this]
}

####################################
# PUBLIC SECURITY GROUPS RESOURCES #
####################################
# By default, AWS creates an ALLOW ALL egress rule when creating a new Security Group inside of a VPC.
resource "aws_security_group" "public_security_group" {
  vpc_id = aws_vpc.this.id
  dynamic "ingress" {
    for_each = var.public_security_group
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Merge all tags
  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_security_group_suffix}-%s",
        var.name, aws_vpc.this.id
      )
    },
    var.tags,
    var.public_security_group_tags,
  )

  depends_on = [aws_vpc.this]
}

#####################################
# PRIVATE SECURITY GROUPS RESOURCES #
#####################################
# By default, AWS creates an ALLOW ALL egress rule when creating a new Security Group inside of a VPC.
resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.this.id
  dynamic "ingress" {
    for_each = var.private_security_group
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Merge all tags
  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_security_group_suffix}-%s",
        var.name, aws_vpc.this.id
      )
    },
    var.tags,
    var.private_security_group_tags,
  )

  depends_on = [aws_vpc.this]
}

##############################
# INTERNET GATEWAY RESOURCES #
##############################
resource "aws_internet_gateway" "internet_gateway" {
  count  = var.create_igw && length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  # Merge all tags
  tags = merge(
    {
      "Name" = format("%s", var.name)
    },
    var.tags,
    var.igw_tags,
  )
  depends_on = [aws_vpc.this, aws_subnet.public_subnet]
}

########################
# ELASTIC IP RESOURCES #
########################
resource "aws_eip" "nat" {
  count = var.enable_nat_gateway ? local.nat_gateway_count : 0
  vpc   = true
  # Merge all tags
  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name, count.index
      )
    },
    var.tags,
    var.nat_eip_tags,
  )
  depends_on = [aws_subnet.public_subnet]
}

#########################
# NAT GATEWAY RESOURCES #
#########################
locals {
  nat_gateway_ips = split(",", join(",", aws_eip.nat.*.id), )
}

resource "aws_nat_gateway" "nat_gateway" {
  count         = var.enable_nat_gateway ? local.nat_gateway_count : 0
  allocation_id = element(local.nat_gateway_ips, count.index, )
  subnet_id     = element(aws_subnet.public_subnet.*.id, count.index, )
  # Merge all tags
  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
    var.nat_gateway_tags,
  )
  depends_on = [aws_internet_gateway.internet_gateway]
}

###########################
# PUBLIC ROUTES RESOURCES #
###########################
resource "aws_route_table" "public_route_table" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_suffix}", var.name)
    },
    var.tags,
    var.public_route_table_tags,
  )
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_igw && length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway[0].id
  timeouts {
    create = var.resources_timeouts
  }
  depends_on = [aws_internet_gateway.internet_gateway, aws_route_table.public_route_table]
}

resource "aws_route" "public_internet_gateway_ipv6" {
  count                       = var.create_igw && var.enable_ipv6 && length(var.public_subnets) > 0 ? 1 : 0
  route_table_id              = aws_route_table.public_route_table[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.internet_gateway[0].id
  depends_on                  = [aws_internet_gateway.internet_gateway, aws_route_table.public_route_table]
}

############################
# PRIVATE ROUTES RESOURCES #
############################
# There are as many routing tables as the number of NAT gateways
resource "aws_route_table" "private_route_table" {
  count  = local.nat_gateway_count
  vpc_id = aws_vpc.this.id
  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_suffix}-%s", var.name, element(var.availability_zones, count.index), )
    },
    var.tags,
    var.private_route_table_tags,
  )
}

resource "aws_route" "private_nat_gateway_to_internet" {
  count                  = var.enable_nat_gateway ? local.nat_gateway_count : 0
  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat_gateway.*.id, count.index)
  timeouts {
    create = var.resources_timeouts
  }
  depends_on = [aws_route_table.private_route_table, aws_nat_gateway.nat_gateway]
}

######################################
# ROUTE TABLE ASSOCIATIONS RESOURCES #
######################################
resource "aws_route_table_association" "custom_public_route_table_association" {
  count          = length(aws_subnet.public_subnet)
  subnet_id      = aws_subnet.public_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table[count.index % length(aws_route_table.public_route_table)].id
  depends_on     = [aws_subnet.public_subnet, aws_route_table.public_route_table]
}

resource "aws_route_table_association" "custom_private_route_table_association" {
  count          = length(aws_subnet.private_subnet)
  subnet_id      = aws_subnet.private_subnet[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index % length(aws_route_table.private_route_table)].id
  depends_on     = [aws_subnet.private_subnet, aws_route_table.private_route_table]
}