data "aws_availability_zones" "fleur-zone" {}

resource "aws_vpc" "fleur-vpc" {
   count = var.create_vpc ? 1 : 0 
  cidr_block                     = var.fleur-cidr-block
  enable_dns_hostnames           = var.enable_dns_hostnames
  enable_dns_support             = var.enable_dns_support
  enable_classiclink             = var.enable_classiclink
  enable_classiclink_dns_support = var.enable_classiclink_dns_support

  tags =  merge(
   {
    Name = format("%s","fleur-vpc")
  }
  )
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_subnet" "fleur-public-subnet" {
  count                   = var.public-subnet-count
  vpc_id                  = aws_vpc.fleur-vpc[0].id
  cidr_block              = [for i in range(0, 100, 2) : cidrsubnet(var.fleur-cidr-block, 8, i)][count.index]
  availability_zone       = data.aws_availability_zones.fleur-zone.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "fleur-public-subnet_${count.index + 1}"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "fleur-private-subnet" {
  count                   = var.private-subnet-count
  vpc_id                  = aws_vpc.fleur-vpc[0].id
  cidr_block              = [for i in range(1, 100, 2) : cidrsubnet(var.fleur-cidr-block, 8, i)][count.index]
  availability_zone       = data.aws_availability_zones.fleur-zone.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "fleur-private-subnet_${count.index + 1}"
  }
  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_internet_gateway" "fleur-gateway" {
  vpc_id = aws_vpc.fleur-vpc[0].id
  tags = {
    Name = "internet-gateway"
  }
}

resource "aws_route_table" "fleur-public-route-table" {
  vpc_id = aws_vpc.fleur-vpc[0].id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.fleur-gateway.id
  }

  tags = {
    Name = "public-route-table"
  }
}


resource "aws_route_table" "fleur-private-route-table" {
  vpc_id = aws_vpc.fleur-vpc[0].id
  tags = {
    Name = "private-route-table"
  }
}


resource "aws_route_table_association" "fleur-public-rt-association" {
  count          = var.public-subnet-count
  subnet_id      = aws_subnet.fleur-public-subnet.*.id[count.index]
  route_table_id = aws_route_table.fleur-public-route-table.id
}


resource "aws_route_table_association" "fleur-private-rt-association" {
  count          = var.private-subnet-count
  subnet_id      = aws_subnet.fleur-private-subnet.*.id[count.index]
  route_table_id = aws_route_table.fleur-private-route-table.id
}

resource "aws_security_group" "fleur-public-security-group" {
  name        = "Public access"
  description = "Allow TCP inbound traffic"
  vpc_id      = aws_vpc.fleur-vpc[0].id

  dynamic "ingress" {
    for_each = local.ingress_rules

    content {
      description = ingress.value.description
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.egree_rule
    iterator = foo

    content {
      from_port        = foo.value.from_port
      to_port          = foo.value.to_port
      protocol         = foo.value.protocol
      cidr_blocks      = foo.value.cidr_blocks
      ipv6_cidr_blocks = ["::/0"]
    }
  }

  tags = {
    Name = "public-security-group"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "fleur-private-security-group" {
  name        = "Private access"
  description = "Allow SSH and Postgresql traffic"
  vpc_id      = aws_vpc.fleur-vpc[0].id

  dynamic "ingress" {
    for_each = local.private
    iterator = pr

    content {
      description = pr.value.description
      from_port   = pr.value.from_port
      to_port     = pr.value.to_port
      protocol    = pr.value.protocol
      cidr_blocks = pr.value.cidr_blocks
    }
  }

  tags = {
    Name = "private-security-group"
  }

}










