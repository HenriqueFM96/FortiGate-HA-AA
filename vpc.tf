// AWS VPC 
resource "aws_vpc" "fgtvm-vpc" {
  cidr_block           = var.vpccidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name = "terraform demo"
  }
}

resource "aws_subnet" "publicsubnet" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.publiccidr
  availability_zone = var.az
  tags = {
    Name = "public subnet"
  }
}

resource "aws_subnet" "privatesubnet" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.privatecidr
  availability_zone = var.az
  tags = {
    Name = "private subnet"
  }
}

resource "aws_subnet" "hasyncsubnet" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.hasynccidr
  availability_zone = var.az
  tags = {
    Name = "hasync subnet"
  }
}

resource "aws_subnet" "hamgmtsubnet" {
  vpc_id            = aws_vpc.fgtvm-vpc.id
  cidr_block        = var.hamgmtcidr
  availability_zone = var.az
  tags = {
    Name = "hamgmt subnet"
  }
}

#############################################################################################################
#                                          SPOKE 01 - VPC                                                   #
#############################################################################################################
resource "aws_vpc" "spoke_vpc1" {
  cidr_block = var.spoke_vpc1_cidr

  tags = {
    Name     = "${var.tag_name_prefix}-vpc-spoke01"
    scenario = var.scenario
  }
}

# Subnets
resource "aws_subnet" "spoke_vpc1-priv1" {
  vpc_id            = aws_vpc.spoke_vpc1.id
  cidr_block        = var.spoke_vpc1_private_subnet_cidr1
  availability_zone = var.availability_zone1

  tags = {
    Name = "${aws_vpc.spoke_vpc1.tags.Name}-priv1"
  }
}

# Routes
resource "aws_route_table" "spoke1-rt" {
  vpc_id = aws_vpc.spoke_vpc1.id

  route {
    cidr_block         = "0.0.0.0/0"
    transit_gateway_id = aws_ec2_transit_gateway.TGW-XAZ.id
  }

  tags = {
    Name     = "spoke-vpc1-rt"
    scenario = var.scenario
  }
  depends_on = [aws_ec2_transit_gateway.TGW-XAZ]
}

# Route tables associations
resource "aws_route_table_association" "spoke1_rt_association1" {
  subnet_id      = aws_subnet.spoke_vpc1-priv1.id
  route_table_id = aws_route_table.spoke1-rt.id
}

resource "aws_security_group" "NSG-spoke2-allow-all" {
  name        = "NSG-spoke2-allow-all"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.spoke_vpc2.id

  ingress {
    description = "Allow any inbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SecurityGroup_Spokes"
    
  }
}

# Subnets
resource "aws_subnet" "spoke_vpc2-priv1" {
  vpc_id            = aws_vpc.spoke_vpc2.id
  cidr_block        = var.spoke_vpc2_private_subnet_cidr1
  availability_zone = var.availability_zone1

  tags = {
    Name = "${aws_vpc.spoke_vpc2.tags.Name}-priv1"
  }
}

