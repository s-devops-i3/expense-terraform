resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env}-vpc"
  }
}

resource "aws_subnet" "frontend" {
  count     = length(var.frontend_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-frontend-subnets-${count.index+1}"
  }
}

resource "aws_subnet" "db" {
  count     = length(var.db_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.db_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-db-subnets-${count.index+1}"
  }
}

resource "aws_subnet" "backend" {
  count     = length(var.backend_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.backend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-backend-subnets-${count.index+1}"
  }
}

resource "aws_subnet" "public" {
  count     = length(var.public_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-public-subnets-${count.index+1}"
  }
}

resource "aws_vpc_peering_connection" "peer" {
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept  = true

  tags = {
    Name = "${var.env}-peer"
  }
}

resource "aws_route" "main" {
  route_table_id            = aws_vpc.main.default_route_table_id
  destination_cidr_block    = var.default_vpc_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_route" "default_vpc" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}
resource "aws_route_table" "frontend" {
  count  = length(var.frontend_subnets)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.default_vpc_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "${var.env}-frontend-rt-${count.index+1}"
  }
}

resource "aws_route_table_association" "frontend" {
  count          = length(var.frontend_subnets)
  subnet_id      = aws_subnet.frontend[count.index].id
  route_table_id = aws_route_table.frontend[count.index].id
}
