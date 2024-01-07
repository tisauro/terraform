


resource "aws_instance" "app_server" {
  ami           = "ami-0e5f882be1900e43b"
  instance_type = "t2.micro"
  # Reference to another resource which can be defined after
  vpc_security_group_ids = [aws_security_group.sg_app_server.id]

  # Variable inside a multistring text
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World!" > index.html
              nohup busybox httpd -f -p ${var.app_server_port} &
              EOF

  user_data_replace_on_change = true
  tags = {
    Name = "Simple Http Server"
  }
}

resource "aws_security_group" "sg_app_server" {
  name        = "sg_http_server"
  description = "Http server security group"
  ingress {
    from_port   = var.app_server_port
    to_port     = var.app_server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Lifecycle introduced in here because when changing the name TF tries to delete the only sg the instance has
  # but this is not possible. Adding the lifecycle new one is created before destroying the current sg
  lifecycle {
    create_before_destroy = true
  }
}

# output definition to return useful information
output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}