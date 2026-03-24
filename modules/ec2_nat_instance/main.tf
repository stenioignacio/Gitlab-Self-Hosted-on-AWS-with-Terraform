data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "nat" {
  name_prefix = format("ec2-nat-%s", var.name)
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_eip" "main" {
  instance = aws_instance.nat.id
  domain   = "vpc"

  tags = {
    Name = "ec2-${aws_instance.nat.tags["Name"]}"
  }
}

resource "aws_eip_association" "main" {
  instance_id   = aws_instance.nat.id
  allocation_id = aws_eip.main.id
}

resource "aws_instance" "nat" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t4g.nano"
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true
  security_groups             = [aws_security_group.nat.id]
  source_dest_check           = false
  monitoring                  = true

  user_data = <<-EOF
              #!/bin/bash
              apt install netfilter-persistent -y
              
              sysctl -w net.ipv4.ip_forward=1
              echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

              iptables -t nat -A POSTROUTING -o ens5 -j MASQUERADE

              # Salva as regras para carregar no boot
              netfilter-persistent save
              netfilter-persistent reload
              EOF

  tags = {
    Name = format("nat-instance-%s", var.account_project_base_name)
  }

  lifecycle {
    ignore_changes = [ami, security_groups, user_data]
  }

  depends_on = [aws_security_group.nat]
}