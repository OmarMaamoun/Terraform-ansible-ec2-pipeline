provider "aws" {
  region = "eu-north-1"  # change region if needed
}

# ───────────────────────────────────────────────
# Security Group to allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"
  vpc_id      = "vpc-098ca694bb886d1db"  

  ingress {
    description = "SSH from anywhere"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ───────────────────────────────────────────────
# EC2 Instance
resource "aws_instance" "my_ec2" {
  ami                         = "ami-09b98de4ddf2fb239"  
  instance_type               = "t3.micro"
  key_name                    = "jenkins-key" 
  subnet_id                   = "subnet-017c7f031b62ab917"  
  vpc_security_group_ids      = [aws_security_group.allow_ssh.id]
  associate_public_ip_address = true  

  tags = {
    Name = "Terraform-EC2"
  }
}

# ───────────────────────────────────────────────
# Output the public IP
output "instance_ip" {
  value       = aws_instance.my_ec2.public_ip
  description = "Public IP of the EC2 instance"
}
