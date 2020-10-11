provider "aws" {
  region     = "eu-west-1"
 }

#Create VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
      Name = "main_vpc"
  }
}

#Create Subnets
resource "aws_subnet" "public_subnet" {
    count                = length(var.availablity_zones)
    vpc_id              = aws_vpc.main_vpc.id
    cidr_block          = cidrsubnet(var.vpc_cidr, 8, count.index)
    availability_zone   = element(var.availablity_zones, count.index)
    map_public_ip_on_launch = true

    tags = {
        Name = "Public Subnet - ${element(var.availablity_zones, count.index)}"
        "kubernetes.io/cluster/mykubernetes" = "shared"
    }
}

resource "aws_subnet" "private_subnet" {
    count                = length(var.availablity_zones)
    vpc_id              = aws_vpc.main_vpc.id
    cidr_block          = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.availablity_zones) + 1 )
    availability_zone   = element(var.availablity_zones, count.index)
    map_public_ip_on_launch = false

    tags = {
        Name = "Private Subnet - ${element(var.availablity_zones, count.index)}"
        "kubernetes.io/cluster/mykubernetes" = "shared"

    }
}

#Create Internet Gateway 
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.main_vpc.id
}

#Create Route tables
resource "aws_route_table" "publicRT" {
    vpc_id              = aws_vpc.main_vpc.id
    tags = {
        Name = " publicRT "
    }

    route  {
    #cidr_block = "${aws_subnet.public_subnet.*.cidr_block[count.index]}"
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "privateRT" {
    vpc_id              = aws_vpc.main_vpc.id
    tags = {
        Name = "privateRT"
    }

    route  {
    #cidr_block = "${aws_subnet.public_subnet.*.cidr_block[count.index]}"
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.gw.id

  }
}



#Create associations
resource "aws_route_table_association" "assosPublicRT" {
    count           = length(var.availablity_zones)
    subnet_id       = aws_subnet.public_subnet.*.id[count.index]
    route_table_id  = aws_route_table.publicRT.id

}

resource "aws_route_table_association" "assosPrivateRT" {
    count           = length(var.availablity_zones)
    subnet_id       = aws_subnet.private_subnet.*.id[count.index]
    route_table_id  = aws_route_table.privateRT.id
}





output "public_subnet" {
  value = aws_subnet.public_subnet.*.id
}

output "private_subnet" {
  value = aws_subnet.private_subnet.*.id
}

output "vpc" {
  value = aws_vpc.main_vpc.id
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {

  #count         = length(var.availablity_zones)
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet[1].id

  tags = {
    Name = "gw NAT"
  }
}
