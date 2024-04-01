terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }
  }
}

provider "aws" {
  region = "us-east-1" # change to your desire region
}

resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16" #adjust the cidr block as needed

  tags = {
    Name = "myVPC"
  }
}
# Creates a subnets 2 public  subnets (web)

resource "aws_subnet" "public_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name = "public_subnet_1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name = "public_subnet_2"
  }
}
# Creates a subnets 4 private  subnets(app)

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1a"
    tags = {
    Name = "private_subnet_1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1b"
   tags = {
    Name = "private_subnet_2"
  }
}

# Creates a 2 private subnets for RDS (DB)

resource "aws_security_group" "my_sg" {
  vpc_id = aws_vpc.my_vpc.id

  # Define your security group rules here
}

resource "aws_lb" "web_lb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.my_sg.id]
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]

  enable_deletion_protection = false

  tags = {
    Name = "WebLB"
  }
}
# configure Autoscaling groups
# resource "aws_autoscaling_group" "my_auto_scaling_group" {
#   launch_configuration = aws_launch_configuration.my_auto_scaling_group.name
#   min_size             = 2
#   max_size             = 6
#   desired_capacity     = 4
#   vpc_zone_identifier  = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
# }

resource "aws_launch_configuration" "launch_configuration" {
  name                        = "launch_configuration"
  image_id                    = "ami-0c101f26f147fa7fd"
  instance_type               = "t2.micro"
  security_groups             = [aws_security_group.my_sg.id]
  key_name                    = "MYKeyPair"
  associate_public_ip_address = true

  lifecycle {
    create_before_destroy = true
  }
}

# resource "aws_db_instance" "db_instance" {
#   allocated_storage    = 20
#   storage_type         = "gp2"
#   engine               = "mysql"
#   engine_version       = "5.7"
#   instance_class       = "db.t2.micro"
#   username             = "admin"
#   password             = "admin123"
#   parameter_group_name = "default.mysql5.7"
#   publicly_accessible  = false

#   subnet_group_name = aws_subnet.private_subnet_3.id

#   tags = {
#     Name = "db_instance"
#   }
# }
# Corrected the VPC ID reference in the public route table.
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id #Yo
  }

  tags = {
    Name = "PublicRouteTable"
  }
}

resource "aws_internet_gateway" "my_igw" {
    vpc_id = aws_vpc.my_vpc.id
    tags = {
    Name = "my_igw"
  }
    
}
# Corrected the VPC ID reference in the private route table.
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "PrivateRouteTable"
  }
}