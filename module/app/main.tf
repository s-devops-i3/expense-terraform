resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "TCP"
    cidr_blocks      = var.server_app_port_sg_cidr
  }

  ingress {
  from_port        = 22
  to_port          = 22
  protocol         = "TCP"
  cidr_blocks      = var.bastion_nodes
}
  ingress {
    from_port        = 9100
    to_port          = 9100
    protocol         = "TCP"
    cidr_blocks      = var.prometheus_nodes
  }

  egress {
  from_port        = 0
  to_port          = 0
  protocol         = "-1"
  cidr_blocks      = ["0.0.0.0/0"]

}
}
#---------Load balancer security group
resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-lbsg"
  description = "${var.component}-${var.env}-lbsg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.component}-${var.env}-lbsg"
  }
  ingress {
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "TCP"
    cidr_blocks      = var.lb_app_port_sg_cidr
  }

  ingress {
    from_port        = 22
    to_port          = 22
    protocol         = "TCP"
    cidr_blocks      = var.bastion_nodes
  }
  ingress {
    from_port        = 9100
    to_port          = 9100
    protocol         = "TCP"
    cidr_blocks      = var.prometheus_nodes
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}
#----Security group for Load Balancer
resource "aws_security_group" "lb-sg" {
  count       = var.lb_needed ? 1 : 0
  name        = "${var.component}-${var.env}-lbsg"
  description = "${var.component}-${var.env}-lbsg"
  vpc_id      = var.vpc_id

  tags = {
    Name = "${var.component}-${var.env}-sg"
  }
  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "instance" {
  ami                    = data.aws_ami.ami.image_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.main.id]
  subnet_id              = var.subnets[0]

    tags = {
      Name = var.component
      monitor = "yes"
      env     = var.env
  }
  lifecycle {
    ignore_changes = [
      ami
    ]
  }
}


resource "null_resource" "ansible" {

  connection {
    type     = "ssh"
    user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
    password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
    host     = aws_instance.instance.private_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install python3.11-devel python3.11-pip -y",
      "sudo pip3.11 install ansible botocore boto3 python-jenkins hvac",
      "ansible-pull -i localhost, -U https://github.com/s-devops-i3/expense-ansible get-secrets.yml -e env=${var.env} -e role_name=${var.component} -e vault_token=${var.vault_token}",
      "ansible-pull -i localhost, -U https://github.com/s-devops-i3/expense-ansible expense.yml -e env=${var.env} -e role_name=${var.component} -e @app.json -e @secrets.json"
    ]
  }
  provisioner "remote-exec" {

    inline = [
      "rm -rf ~/app.json ~/secrets.json"
    ]
  }
}

resource "aws_route53_record" "server" {
  count   = var.lb_needed ? 0 : 1
  name    = "${var.component}-${var.env}"
  type    = "A"
  zone_id = var.zone_id
  records = [aws_instance.instance.private_ip]
  ttl     = 30
}
resource "aws_route53_record" "lb" {
  count   = var.lb_needed ? 1 : 0
  name    = "${var.component}-${var.env}-alb"
  type    = "CNAME"
  zone_id = var.zone_id
  records = [aws_lb.main[0].dns_name]
  ttl     = 30
}

#
resource "aws_lb" "main" {
  count              = var.lb_needed ? 1 : 0
  name               = "${var.env}-${var.component}-alb"
  internal           = var.lb_type == "Public" ? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb-sg[0].id]
  subnets            = var.lb_subnet

  tags = {
    Environment = "${var.env}-${var.component}-alb"
  }
}
resource "aws_lb_target_group" "main" {
  count    = var.lb_needed ? 1 : 0
  name     = "${var.env}-${var.component}-tg"
  port     = var.app_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  deregistration_delay = 15

  health_check {
    healthy_threshold   = 2
    interval            = 5
    path                = "/health"
    port                = var.app_port
    timeout             = 2
    unhealthy_threshold = 2
  }
}
resource "aws_lb_target_group_attachment" "main" {
  count            = var.lb_needed ? 1 : 0
  target_group_arn = aws_lb_target_group.main[0].arn
  target_id        = aws_instance.instance.id
  port             = var.app_port
}

resource "aws_lb_listener" "main" {
  count             = var.lb_needed ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}
