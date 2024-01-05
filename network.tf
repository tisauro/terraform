resource "aws_vpc" "test_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    project = "terraform",
    Name    = "test-vpc"
  }
}

# Declare the data source
data "aws_availability_zones" "azs" {
  state = "available"
}

# e.g., Create subnets in the first two available availability zones


resource "aws_subnet" "private_2a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    Name = "private-sub-2a"
  }
}

resource "aws_subnet" "private_2b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]
  tags = {
    Name = "private-sub-2b"
  }
}

resource "aws_subnet" "private_2c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.azs.names[2]
  tags = {
    Name = "private-sub-2c"
  }
}

resource "aws_subnet" "public_2a" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.azs.names[0]
  tags = {
    Name = "public-sub-2a"
  }
}

resource "aws_subnet" "public_2b" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = data.aws_availability_zones.azs.names[1]
  tags = {
    Name = "public-sub-2b"
  }
}

resource "aws_subnet" "public_2c" {
  vpc_id            = aws_vpc.test_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = data.aws_availability_zones.azs.names[2]
  tags = {
    Name = "public-sub-2c"
  }
}