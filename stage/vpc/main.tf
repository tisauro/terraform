terraform {
  backend "s3" {
    bucket = "tisauro-terraform-running-state"
    key = "stage/vpc/terraform.tfstate"
    region = "eu-west-2"

    dynamodb_table = "terraform-state-locks"
    encrypt = true
  }
}

resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    project = "terraform",
    Name    = "test-vpc"
  }
}

resource "aws_internet_gateway" "vpc_test_ig" {
  vpc_id = aws_vpc.test_vpc.id
  tags   = {
    Name = "VPC Test IG"
  }
}

# Declare the data source
data "aws_availability_zones" "azs" {
  state = "available"
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_test_ig.id
  }
  tags   = {
    Name = "Public Route Table"
  }

}

resource "aws_route_table" "private_route_table_with_nat" {
  vpc_id = aws_vpc.test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway_2a.id
  }
  tags   = {
    Name = "Private Route Table With NAT"
  }
}


resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.test_vpc.id

  tags   = {
    Name = "Private Route Table"
  }
}


# e.g., Create subnets in the first two available availability zones


resource "aws_subnet" "private_2a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags              = {
    Name = "private-sub-2a"
  }
}

resource "aws_subnet" "private_2b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]
  tags              = {
    Name = "private-sub-2b"
  }
}

resource "aws_subnet" "private_2c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.azs.names[2]
  tags              = {
    Name = "private-sub-2c"
  }
}

resource "aws_subnet" "private_with_nat_2a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags              = {
    Name = "private-sub-with-nat-2a"
  }
}

resource "aws_subnet" "private_with_nat_2b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]
  tags              = {
    Name = "private-sub-with-nat-2b"
  }
}

resource "aws_subnet" "private_with_nat_2c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = data.aws_availability_zones.azs.names[2]
  tags              = {
    Name = "private-sub-with-nat-2c"
  }
}

#resource "aws_nat_gateway" "vpc_test_nat" {
#  allocation_id = ""
#  subnet_id     = ""
#}


resource "aws_subnet" "public_2a" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.10.0/24"
  availability_zone       = data.aws_availability_zones.azs.names[0]
  map_public_ip_on_launch = true
  tags                    = {
    Name = "public-sub-2a"
  }
}

resource "aws_subnet" "public_2b" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.azs.names[1]
  map_public_ip_on_launch = true
  tags                    = {
    Name = "public-sub-2b"
  }
}

resource "aws_subnet" "public_2c" {
  vpc_id                  = aws_vpc.test_vpc.id
  cidr_block              = "10.0.12.0/24"
  availability_zone       = data.aws_availability_zones.azs.names[2]
  map_public_ip_on_launch = true
  tags                    = {
    Name = "public-sub-2c"
  }
}

resource "aws_route_table_association" "public-2a-to-public-rt" {
  subnet_id      = aws_subnet.public_2a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public-2b-to-public-rt" {
  subnet_id      = aws_subnet.public_2b.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public-2c-to-public-rt" {
  subnet_id      = aws_subnet.public_2c.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private-2a-nat-to-private-rt" {
  subnet_id      = aws_subnet.private_with_nat_2a.id
  route_table_id = aws_route_table.private_route_table_with_nat.id
}

resource "aws_route_table_association" "private-2b-nat-to-private-rt" {
  subnet_id      = aws_subnet.private_with_nat_2b.id
  route_table_id = aws_route_table.private_route_table_with_nat.id
}

resource "aws_route_table_association" "private-2c-nat-to-private-rt" {
  subnet_id      = aws_subnet.private_with_nat_2c.id
  route_table_id = aws_route_table.private_route_table_with_nat.id
}

resource "aws_route_table_association" "private-2a-to-private-rt" {
  subnet_id      = aws_subnet.private_2a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private-2b-to-private-rt" {
  subnet_id      = aws_subnet.private_2b.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private-2c-to-private-rt" {
  subnet_id      = aws_subnet.private_2c.id
  route_table_id = aws_route_table.private_route_table.id
}


resource "aws_eip" "nat_gateway_eip" {
  depends_on = [aws_internet_gateway.vpc_test_ig]
}

resource "aws_nat_gateway" "nat_gateway_2a" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_2a.id

  tags = {
    Name = "gw NAT"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.vpc_test_ig]
}

