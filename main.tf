provider "aws"{
  region = "eu-west-2"  
}

resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.cidr_blocks[0]
  tags = {
    Name = var.cidr_blocks[0]
    vpc_env = "dev"
  }
}

variable "environment" {
  description = "deployment environment"
  default = "My-app-dev-VPC"
}

variable "cidr_blocks" {
  description = "cidr blocks for vpc and subnets"
  type = list(string)
}


/* variable "cidr_blocks" {
  description = "cidr blocks for vpc and subnets"
  type = list(object({
    cidr_block = string
    name = string
  }))
} */

resource "aws_subnet" "my-app-subnet-1" {
  vpc_id = aws_vpc.my-app-vpc.id
  cidr_block = var.cidr_blocks[1]
  availability_zone = "eu-west-2a"
  tags = {
    Name = "subnet-1-dev"
  }
}

 /* resource "aws_subnet" "my-app-subnet-1" {
  vpc_id = aws_vpc.my-app-vpc.id
  cidr_block = var.cidr_blocks[1].cidr_block
  availability_zone = "eu-west-2a"
  tags = {
    Name = var.cidr_blocks[1].cidr_block.name
  }
} */

output "dev-vpc-id" {
  value = aws_vpc.my-app-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.my-app-subnet-1.id
}