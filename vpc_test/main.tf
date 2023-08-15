resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "custom_vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "custom_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  tags = {
    Name = "public_subnet"
  }
}

resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "Public Routing Table"
  }
}

resource "aws_route" "public_subnet_internet_gateway_ipv4" {
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_subnet_internet_gateway_ipv6" {
  route_table_id              = aws_route_table.rt.id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.rt.id
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC4lP9HjJyaNBM2ChqvjCe1dvTzdegQnodq0N57U3zjRy9y2+mM5Zl9C90QDAU2cgwU28q3UUfBe3ZBp6HMU1nxG3kMCz5B7g35ph3c2r08GgL/DcEUb0Iki/XFC7BVAAFfFfISNMRwCola+7/ldFtjY4pTjhs4ChiZFdljhYbl1LpG6GoMHxRZIluRxulOPYB/kSFJKFtJb5h5ZrQCE7d2RtPYOS3qwzVplMA7PsmShzN5EHWwHuE+aoHtT6970yoN9MrCZjoXUmsIGekUcgUqy1OA8e6qgawEx4pl+EjZ3w4F0pMr1AqJbqlkB6uyyKaVxQQ5iXq2MQcawLto1pT23o8xBqBalOucR/lIva1NSMUV7RWvEht0bRJo1BkWdrr0dkTA/KQ5UVjyoO2IvIVSkklUs4xwozkuyzpTAFGazjmjaEj5X823bsDmpKuaf85NgFbnc4Un4rYVqY7sDrBLbciztHGwtidkEOpCBMm4X+bFVBEnFmPQVM5VatcCt50= hieupc"
}

resource "aws_security_group" "forwarder" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    description = "ssh"
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "http"
    from_port   = 80
    protocol    = "tcp"
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "instance" {
  subnet_id                   = aws_subnet.public_subnet.id
  ami                         = "ami-002843b0a9e09324a"
  instance_type               = "t2.micro"
  key_name                    = "deployer-key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.forwarder.id]
}



