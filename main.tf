provider "aws" {
  region = var.aws_region
  access_key = var.access_key
  secret_key = var.secret_key
}

resource "aws_vpc" "my-vpc" {
    cidr_block  = var.vpc_cidr_block
    instance_tenancy  = var.vpc_tenancy
    tags = {
      Name = "IaC_VPC"
      Environment = var.environment
    }
}

data "aws_availability_zones" "azs" { }

resource "aws_subnet" "subnets" {
    count = length(data.aws_availability_zones.azs.names)
    vpc_id = aws_vpc.my-vpc.id
    cidr_block = cidrsubnet(aws_vpc.my-vpc.cidr_block, 8, count.index+1)
    map_public_ip_on_launch = true
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    tags = {
      Name = "Subnet-${count.index+1}"
      Environment = var.environment
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id =  aws_vpc.my-vpc.id
    tags = {
      Name = "IaC-IGW"
      Environment = var.environment
    }
}

output "val-id" {
  value = aws_internet_gateway.igw.id

}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.my-vpc.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.igw.id
    }
     tags = {
      Environment = var.environment
    }   
}

resource "aws_route_table_association" "rtas" {
    count = length(aws_subnet.subnets)
    subnet_id = aws_subnet.subnets[count.index].id
    route_table_id  = aws_route_table.public.id
}


resource "aws_instance" "servers" {

  count = var.vm_count
  ami = var.ami
  instance_type = var.instance_type
  subnet_id = aws_subnet.subnets[(count.index % 2 ) + 1].id
  #user_data = "${file("httpd.sh")}"
  key_name  = "iac_aws"
  vpc_security_group_ids  = [aws_security_group.allow.id]
  tags = {
    Name = "Server-${count.index+1}"
    Environment = var.environment
  }
}

resource "aws_security_group" "allow" {
    vpc_id = aws_vpc.my-vpc.id
    name = "iacsg${var.environment}"
    ingress {
      from_port = 0
      to_port = 0
      protocol  = -1
      cidr_blocks  = var.sg_cidr_blocks
    }
    egress {
      from_port = 0
      to_port = 0
      protocol  = -1
      cidr_blocks  = ["0.0.0.0/0"]
    }
  tags = {
    Name = "IaC - SG"
    Environment = var.environment
  }
}
