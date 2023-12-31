provider "aws"{
  region = "eu-west-2"  
}
variable vpc_cidr_block{}
variable subnet_cidr_block{}
variable avail_zone{}
variable env_prefix {}
variable my_ip{}
variable instance_type{}
variable my_public{}
# variable public_key_location{}

resource "aws_vpc" "my-app-vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

resource "aws_subnet" "my-app-subnet-1" {
  vpc_id = aws_vpc.my-app-vpc.id
  cidr_block = var.subnet_cidr_block
  availability_zone = var.avail_zone
  tags = {
    Name = "${var.env_prefix}-subnet-1"
  }
}

output "dev-vpc-id" {
  value = aws_vpc.my-app-vpc.id
}

output "dev-subnet-id" {
  value = aws_subnet.my-app-subnet-1.id
}

output "ec2_public_ip" {
  value = aws_instance.app-server.public_ip
}


resource "aws_internet_gateway" "myapp-igw" {
  vpc_id = aws_vpc.my-app-vpc.id
  tags={
    Name = "${var.env_prefix}-igw" 
  }
}
resource "aws_route_table" "myapp-route-table" {
  vpc_id = aws_vpc.my-app-vpc.id 
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.myapp-igw.id
  }
  tags = {
    Name = "${var.env_prefix}-rt"
  }
}

resource "aws_route_table_association" "a-rt-subnet" {
  subnet_id = aws_subnet.my-app-subnet-1.id
  route_table_id = aws_route_table.myapp-route-table.id
}

resource "aws_security_group" "myapp-sg" {
  name = "myapp-sg"
  vpc_id = aws_vpc.my-app-vpc.id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks =  [ "0.0.0.0/0" ]   #[ var.my_ip ]
  }

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }

  egress {
   from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [ "0.0.0.0/0" ] 
  }
  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

  /* data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
 


resource "aws_instance" "myapp-server" {
   ami = data.aws_ami.latest-amazon-linux-image.id
   instance_type = var.instance_type

   subnet_id = aws_subnet.my-app-subnet-1.id
   security_groups = [aws_security_group.myapp-sg.id]
   availability_zone = var.avail_zone

   associate_public_ip_address = true
   key_name = "class29"

   tags = {
    Name = "${var.env_prefix}-server"
  }


}  */

resource "aws_key_pair" "ssh-key" {
  key_name = "server-key"
  public_key = var.my_public
  # public_key = file(var.public_key_location)
}

resource "aws_instance" "app-server" {
  ami = "ami-0b026d11830afcbac"
  instance_type = var.instance_type
  subnet_id = aws_subnet.my-app-subnet-1.id
  security_groups = [ aws_security_group.myapp-sg.id ]
  availability_zone = var.avail_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name

  user_data = file("entry-script.sh")
   tags = {
    Name = "${var.env_prefix}-EC2-server"
  }
}