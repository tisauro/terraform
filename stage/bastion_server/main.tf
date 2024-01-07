resource "aws_security_group" "bastion_sg" {
  description = "Bastion server Security Group"
  vpc_id      = aws_vpc.test_vpc.id
  ingress {
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
  tags = {
    Name = "Bastion-sg"
  }
}

resource "aws_instance" "bastion" {
  ami             = "ami-0e5f882be1900e43b"
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.public_2a.id
  security_groups = [aws_security_group.bastion_sg.id]
  tags            = {
    Name = "Bastion Server"
  }
}