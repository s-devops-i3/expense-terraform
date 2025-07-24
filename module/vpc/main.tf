resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = "${var.env}-vpc"
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


resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.env}-igw"
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



# resource "aws_route_table" "public" {
#   count  = length(var.public_subnets)
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block = var.default_vpc_cidr
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }
#   # route {
#   #   cidr_block = "0.0.0.0/0"
#   #   gateway_id = aws_internet_gateway.igw.id
#   # }
#
#   tags = {
#     Name = "${var.env}-public-rt-${count.index+1}"
#   }
# }

# resource "aws_eip" "eip" {
#   count             = length(var.public_subnets)
#   domain            = "vpc"
#   }

# resource "aws_nat_gateway" "ngw" {
#   count  = length(var.public_subnets)
#   allocation_id = aws_eip.eip[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id
#
#   tags = {
#     Name = "${var.env}-ngw-${count.index+1}"
#   }
# }

# resource "aws_route_table_association" "public" {
#   count          = length(var.public_subnets)
#   subnet_id      = aws_subnet.public[count.index].id
#   route_table_id = aws_route_table.public[count.index].id
# }

resource "aws_subnet" "frontend" {
  count     = length(var.frontend_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.frontend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-frontend-subnets-${count.index+1}"
  }
}

# resource "aws_route_table" "frontend" {
#   count  = length(var.frontend_subnets)
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block = var.default_vpc_cidr
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }
#   # route {
#   #   cidr_block = "0.0.0.0/0"
#   #   nat_gateway_id = aws_nat_gateway.ngw[count.index].id
#   # }
#
#   tags = {
#     Name = "${var.env}-frontend-rt-${count.index+1}"
#   }
# }

# resource "aws_route_table_association" "frontend" {
#   count          = length(var.frontend_subnets)
#   subnet_id      = aws_subnet.frontend[count.index].id
#   route_table_id = aws_route_table.frontend[count.index].id
# }


resource "aws_subnet" "db" {
  count     = length(var.db_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.db_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-db-subnets-${count.index+1}"
  }
}

# resource "aws_route_table" "db" {
#   count  = length(var.db_subnets)
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block = var.default_vpc_cidr
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }
#   # route {
#   #   cidr_block = "0.0.0.0/0"
#   #   nat_gateway_id = aws_nat_gateway.ngw[count.index].id
#   # }
#   tags = {
#     Name = "${var.env}-db-rt-${count.index+1}"
#   }
# }

# resource "aws_route_table_association" "db" {
#   count          = length(var.db_subnets)
#   subnet_id      = aws_subnet.db[count.index].id
#   route_table_id = aws_route_table.db[count.index].id
# }


resource "aws_subnet" "backend" {
  count     = length(var.backend_subnets)
  vpc_id     = aws_vpc.main.id

  cidr_block = var.backend_subnets[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.env}-backend-subnets-${count.index+1}"
  }
}

# resource "aws_route_table" "backend" {
#   count  = length(var.backend_subnets)
#   vpc_id = aws_vpc.main.id
#
#   route {
#     cidr_block = var.default_vpc_cidr
#     vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
#   }
#   # route {
#   #   cidr_block = "0.0.0.0/0"
#   #   nat_gateway_id = aws_nat_gateway.ngw[count.index].id
#   # }
#   tags = {
#     Name = "${var.env}-backend-rt-${count.index+1}"
#   }
# }

# resource "aws_route_table_association" "backend" {
#   count          = length(var.backend_subnets)
#   subnet_id      = aws_subnet.backend[count.index].id
#   route_table_id = aws_route_table.backend[count.index].id
# }

resource "aws_route" "default_vpc" {
  route_table_id            = var.default_route_table_id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}


