terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-2"
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0e5f882be1900e43b"
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.sg_app_server.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World!" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF

  user_data_replace_on_change = true
  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_security_group" "sg_app_server" {
  name = "sg_app_server"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}