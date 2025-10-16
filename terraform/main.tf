provider "aws" {
  region = "eu-north-1"
}

resource "aws_instance" "my_ec2" {
  ami           = "ami-09b98de4ddf2fb239" # Amazon Linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "Terraform-EC2"
  }

  
  key_name = "rsa"
}

output "instance_ip" {
  value = aws_instance.my_ec2.public_ip
}
