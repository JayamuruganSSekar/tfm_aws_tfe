variable "aws_region" {
  default = "us-east-2"
}
variable "access_key" {}
variable "secret_key" { }
variable "vpc_cidr_block" { }
variable "vpc_tenancy" { 
  default = "default"
}
variable vm_count {
  default = "1"
}
variable "ami" { }
variable "instance_type" { }
variable "environment" { 
  default = "dev"
}
variable "sg_cidr_blocks" { 
  default = ["136.1.0.0/16", "136.2.0.0/16"]
}
