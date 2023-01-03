
# 1. create vpc
resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"
}


# 2. create IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Internet-gateway"
  }
}



# 3. create RouteTable
resource "aws_route_table" "public-route-to-igw" {
  vpc_id = aws_vpc.vpc.id

  tags = { 
    Name = "Public Routing Table"
  }
}

resource "aws_route" "public_subnet_internet_gateway_ipv4" {
  route_table_id         = aws_route_table.public-route-to-igw.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_subnet_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.public-route-to-igw.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}


# 4. create Subnet
resource "aws_subnet" "public_subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public_subnet1"
  }
}

resource "aws_subnet" "private_subnet1" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  tags = {
    Name = "private_subnet1"
  }
}

resource "aws_subnet" "public_subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  tags = {
    Name = "public_subnet2"
  }
}

resource "aws_subnet" "private_subnet2" {
  vpc_id = aws_vpc.vpc.id
  cidr_block = "10.0.4.0/24"
  tags = {
    Name = "private_subnet2"
  }
}


resource "aws_eip" "public_AZ1" {
  vpc = true
}

# Create NAT Gateways ##
resource "aws_nat_gateway" "nat_AZ1" {
  allocation_id = aws_eip.public_AZ1.id
  subnet_id     = aws_subnet.public_subnet1.id

  depends_on = [aws_internet_gateway.igw]

  tags = { 
    Name = "First AZ NAT Gateway"
  }
}



# 5. create Associate subnet with route table
resource "aws_route_table_association" "public_AZ1" {
  subnet_id      = aws_subnet.public_subnet1.id
  route_table_id = aws_route_table.public-route-to-igw.id
}

resource "aws_route_table_association" "public_AZ2" {
  subnet_id      = aws_subnet.public_subnet2.id
  route_table_id = aws_route_table.public-route-to-igw.id
}


# 6. Security Group port 22 and 80
resource "aws_security_group" "forwarder" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    description = "http"
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. Create key-pair
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1d0QT4dphmfralZB9U4FjOvg2aSt3mqDROe79sgIXMah9gOayJhbMIFSw/dnmYwSRxN6SiSbBL1ddubFPiM485B1/XxbV0w2ePODEZdeTi+B3Sm8+ECL6iEgE2lHIGQHINVAip1SIsfRZ1/AtHxdvBgQi4iqJSnctcSr5ujINinEgeHs+zoQGZxIgyBSpDPEdCjMVwbujjoBJXkVRxVzRzN2PcAxGzHobzXDMQ0IGJ2yeS/CmNpVLhXORe+HFv3jTwgMvzLb1QekdtV1PCBsbUnjEmpo1rsaCWQSaS9fGdqRhgocH21k+j97KIJwGrKv6q7xrHe9FUPy+bGftaCTKlAuE0c3A6/48ivebkTyMxOK2jCZyOe369xTSPbCxhxqUeaIttyzMw+mcQMNRsphxCAT6g9eQfBAXlPR4fJSPAmueUZ54jslJNy0s/fzMAZQptKQZBs4m6caxwuM5K0hpHoUTQHHZ46MM/RI2Hzhv6xMQUhYzrxevR+45zjmtV+E= chihieu@chihieu-G5-5587"
}

data "aws_ami" "amazon-linux-2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}


# 8. Create ec2
resource "aws_instance" "instance" {
  subnet_id     = aws_subnet.public_subnet1.id
  ami           = "ami-06df38320cecdd700"
  instance_type = "t2.micro"
  key_name       = "deployer-key"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.forwarder.id]
}


## Create EIPs ##
resource "aws_eip" "public_AZ2" {
  vpc = true
}

# locals {
#   test = {
#     for k, v in var.users_test : k => v 
#   }
# }

# output "data" {
#   value = local.test
# }

