provider "aws" {
  version    = "2.55.0"
  region     = "us-east-1"
}
# AWS vpc
resource "aws_vpc" "vpc" {
  cidr_block = "192.168.0.0/16"

  tags = {
    Name = "AzureAWSPeering"
  }
}
# AWS public subnet
resource "aws_subnet" "subnet_1" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "AzureAWSPeering_AWS_Public_Subnet"
  }
}
# AWS private subnet
resource "aws_subnet" "subnet_2" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "192.168.2.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "AzureAWSPeering_AWS_Private_Subnet"
  }
}
# AWS public route table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "AzureAWSPeering_public_route_table"
  }
}
# AWS public subnet and public route table association
resource "aws_route_table_association" "route_table_association_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}
# AWS private route table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "AzureAWSPeering_private_route_table"
  }
}
# AWS private subnet and private route table association
resource "aws_route_table_association" "route_table_association_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.private_route_table.id
}
# AWS internet gateway & internet gateway route in route table
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "AzureAWSPeering_internet_gateway"
  }
}
resource "aws_route" "subnet_1_exit_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.internet_gateway.id
}
