##############################################################################################################
#                                        Spoke Instances - LAMP by Bitnami                                   #
##############################################################################################################
/*
## Retrieve AMI info
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}
*/

# test device in spoke1
resource "aws_instance" "instance-spoke1" {
  ami                    = var.spoke_instances
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.spoke_vpc1-priv1.id
  vpc_security_group_ids = [aws_security_group.NSG-spoke1-allow-all.id]
  key_name               = var.keypair

  tags = {
    Name     = "WebServer"
  }
}

# test device in spoke2
resource "aws_instance" "instance-spoke2" {
  ami                    = var.spoke_instances
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.spoke_vpc2-priv1.id
  vpc_security_group_ids = [aws_security_group.NSG-spoke2-allow-all.id]
  key_name               = var.keypair

  tags = {
    Name     = "WebServer"
    scenario = "replication"
  }
}

# test device in mgmt
/*
resource "aws_instance" "instance-mgmt" {
  ami                         = var.spoke_instances
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.spoke_mgmt-priv1.id
  vpc_security_group_ids      = [aws_security_group.NSG-mgmt-allow-all.id]
  key_name                    = var.keypair
  associate_public_ip_address = true

  tags = {
    Name     = "instance-${var.tag_name_unique}-mgmt"
    scenario = var.scenario
    az       = var.availability_zone1
  }
}
*/
