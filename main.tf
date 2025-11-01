# VPC
resource "aws_vpc" "main-vpc" {
  cidr_block       = var.cidr_block
  instance_tenancy = "default"

  tags = {
    Name = "terraform-vpc"
  }
}

# Public Subnet
resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.public_subnet_cidr

  tags = {
    Name = "vpc-public-subnet"
  }
}

# Private Subnet
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main-vpc.id
  cidr_block = var.private_subnet_cidr

  tags = {
    Name = "vpc-private-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main-vpc.id

  tags = {
    Name = "IGW-for-terraform"
  }
}

# Route Table for Public Subnet
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Associate Public Subnet with Route Table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# User Data for Nginx
data "template_file" "user_data" {
  template = file("install_nginx.sh")
}

# Security Group for EC2 Instance
resource "aws_security_group" "web_sg" {
  name        = "web-server-sg"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = aws_vpc.main-vpc.id

  # Inbound rules (allow traffic to instance)
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]   # open to all (use carefully)
  }

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound rules (allow all outgoing)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "WebServer-SG"
  }
}

resource "aws_instance" "web-server" {
  ami                         = "ami-01760eea5c574eb86"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public.id
  associate_public_ip_address  = true
  user_data                   = data.template_file.user_data.rendered
  vpc_security_group_ids       = [aws_security_group.web_sg.id]   # <--- Added this

  tags = {
    Name = "Public-Web-Server"
  }
}
