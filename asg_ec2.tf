# define how the http servers must be built
resource "aws_launch_configuration" "http_asg_configuration" {
  image_id        = "ami-0e5f882be1900e43b"
  instance_type   = "t2.micro"
  name_prefix     = "terraform_practice_"
  security_groups = [aws_security_group.sg_app_server.id]

  # Variable inside a multistring text
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello World!" > index.html
              nohup busybox httpd -f -p ${var.app_server_port} &
              EOF


  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "sg_app_server" {
  name        = "sg_http_server"
  description = "Http server security group"
  vpc_id      = aws_vpc.test_vpc.id
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

resource "aws_autoscaling_group" "http_asg" {
  launch_configuration = aws_launch_configuration.http_asg_configuration.name
  vpc_zone_identifier  = [aws_subnet.private_2a.id, aws_subnet.private_2b.id, aws_subnet.private_2c.id]

  target_group_arns = [aws_alb_target_group.alb_http_target_group.arn]
  health_check_type = "ELB"
  min_size          = 1
  max_size          = 3
  desired_capacity  = 2
  name_prefix       = "terraform_practice_"


  tag {
    key                 = "Name"
    propagate_at_launch = true
    value               = "http-asg"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "alb_sg" {
  name = "Http ALB security group"
  vpc_id = aws_vpc.test_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
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

resource "aws_alb" "http_alb" {
  name               = "http-alb"
  load_balancer_type = "application"
  subnets            = [aws_subnet.public_2a.id, aws_subnet.public_2b.id, aws_subnet.public_2c.id]
  security_groups    = [aws_security_group.alb_sg.id]
}

resource "aws_alb_listener" "http_alb_listener" {
  load_balancer_arn = aws_alb.http_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_alb_listener_rule" "alb_http_listening_rule" {
  listener_arn = aws_alb_listener.http_alb_listener.arn
  priority = 100
  condition {
    path_pattern {
      values = ["*"]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_alb_target_group.alb_http_target_group.arn
  }
}

resource "aws_alb_target_group" "alb_http_target_group" {
  name     = "ALB-HTTP-Target-Group"
  port     = var.app_server_port
  protocol = "HTTP"
  vpc_id   = aws_vpc.test_vpc.id
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

output "alb_dns" {
  value = aws_alb.http_alb.dns_name
  description = "The domain name of the alb"
}