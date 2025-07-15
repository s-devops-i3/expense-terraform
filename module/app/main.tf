resource "aws_security_group" "main" {
  name        = "${var.component}-${var.env}-sg"
  description = "${var.component}-${var.env}-sg"
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
  subnet_id              = var.db_subnet[0]

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
# -----Creating Load Balancer
resource "aws_lb" "main" {
  count              = var.lb_needed ? 1 : 0
  name               = "${var.env}-${var.component}-alb"
  internal           = var.lb_type == "public" ? false : true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets            = var.lb_subnet

  tags = {
    Environment = "${var.env}-${var.component}-alb"
  }
}
#-----Creating Target Group
resource "aws_lb_target_group" "main" {
  count    = var.lb_needed ? 1 : 0
  name     = "${var.env}-${var.component}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id
}
#---Creating Listener
resource "aws_lb_listener" "front" {
  count    = var.lb_needed ? 1 : 0
  load_balancer_arn = aws_lb.main[0].arn
  port              = var.app_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main[0].arn
  }
}

#---Creating Target Group Attachment
resource "aws_lb_target_group_attachment" "main" {
  count            = var.lb_needed ? 1 : 0
  target_group_arn = aws_lb_target_group.main[0].arn
  target_id        = aws_instance.instance.id
  port             = var.app_port
}


resource "aws_route53_record" "record" {
  name    = "${var.component}-${var.env}"
  type    = "A"
  zone_id = var.zone_id
  records = [aws_instance.instance.private_ip]
  ttl     = 30
}
