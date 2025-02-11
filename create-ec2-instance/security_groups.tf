resource "aws_security_group" "public" {
  name        = "tech257-farah-tf-allow-port-22-3000-80"
  description = "Setup for our first EC2 instance"
  vpc_id      = "vpc-07e47e9d90d2076da"

  tags = {
    Name = "tech257-farah-tf-allow-port-22-3000-80"
  }
}

resource "aws_security_group_rule" "public_out" {
  type        = "egress"
  from_port   = 0
  to_port     = 0
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_ssh_local_host_only" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["127.0.0.1/32"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_http_all" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}

resource "aws_security_group_rule" "public_in_app_all" {
  type              = "ingress"
  from_port         = 3000
  to_port           = 3000
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.public.id
}
