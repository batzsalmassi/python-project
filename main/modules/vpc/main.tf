resource "aws_vpc" "mainVPC" {
  cidr_block           = var.cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = merge(
    {
      Name = format("%s-vpc", var.name)
    },
    var.tags
  )
}

data "aws_availability_zones" "available" {}

resource "aws_subnet" "public" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.mainVPC.id
  cidr_block              = cidrsubnet(var.cidr, 8, count.index + 1)
  availability_zone       = element(data.aws_availability_zones.available.names, count.index)
  map_public_ip_on_launch = true

  tags = merge(
    {
      Name = format("%s-public-subnet-%d", var.name, count.index + 1)
    },
    var.tags
  )
}

resource "aws_subnet" "private" {
  count             = var.private_subnet_count
  vpc_id            = aws_vpc.mainVPC.id
  cidr_block        = cidrsubnet(var.cidr, 8, var.public_subnet_count + count.index + 1)
  availability_zone = element(data.aws_availability_zones.available.names, count.index)

  tags = merge(
    {
      Name = format("%s-private-subnet-%d", var.name, count.index + 1)
    },
    var.tags
  )
}

resource "aws_internet_gateway" "main-igw" {
  vpc_id = aws_vpc.mainVPC.id

  tags = merge(
    {
      Name = format("%s-igw", var.name)
    },
    var.tags
  )
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.mainVPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet" {
  count = var.public_subnet_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public-rt.id
}

resource "aws_route_table" "private-rt" {
  vpc_id = aws_vpc.mainVPC.id

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private_subnet" {
  count = var.private_subnet_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private-rt.id
}
