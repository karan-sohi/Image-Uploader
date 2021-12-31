provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_vpc" "some_custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Some Custom VPC"
  }
}

resource "aws_subnet" "nginx_public_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Nginx Public Subnet For Reverse Proxy"
  }
}

resource "aws_subnet" "node_private_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Node Private Subnet"
  }
}

  resource "aws_subnet" "database_private_subnet" {
  vpc_id            = aws_vpc.some_custom_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Database Private Subnet"
  }
}


resource "aws_internet_gateway" "some_ig" {
  vpc_id = aws_vpc.some_custom_vpc.id

  tags = {
    Name = "Some Internet Gateway"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.some_custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.some_ig.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.some_ig.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_1_rt_a" {
  subnet_id      = aws_subnet.nginx_public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


resource "aws_security_group" "rp_sg" {
  name   = "Reverse Proxy Security Group"
  vpc_id = aws_vpc.some_custom_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "node_sg" {
  name   = "Node Security Group"
  vpc_id = aws_vpc.some_custom_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_security_group" "mongo_sg" {
  name   = "Mongo security group"
  vpc_id = aws_vpc.some_custom_vpc.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "nginx_instance" {
  ami           = "NGINX_AMI_ID"
  instance_type = "t2.micro"
  key_name      = "aws-key-pair"

  subnet_id                   = aws_subnet.nginx_public_subnet.id
  vpc_security_group_ids      = [aws_security_group.rp_sg.id]
  associate_public_ip_address = true

}


resource "aws_instance" "node_instance" {
  ami           = "NODE_AMI_ID"
  instance_type = "t2.micro"
  key_name      = "aws-key-pair"
  private_ip    = "10.0.2.10"

  subnet_id                   = aws_subnet.node_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.node_sg.id]
  associate_public_ip_address = true

}

resource "aws_instance" "mongo_instance" {
  ami           = "MONGO_AMI_ID"
  instance_type = "t2.micro"
  key_name      = "aws-key-pair"
  private_ip    = "10.0.3.10"

  subnet_id                   = aws_subnet.database_private_subnet.id
  vpc_security_group_ids      = [aws_security_group.mongo_sg.id]
  associate_public_ip_address = true

}