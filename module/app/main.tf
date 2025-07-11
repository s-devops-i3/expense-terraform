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
}


# resource "null_resource" "ansible" {
#   provisioner "remote-exec" {
#
#     connection {
#       type     = "ssh"
#       user     = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_user
#       password = jsondecode(data.vault_generic_secret.ssh.data_json).ansible_password
#       host     = aws_instance.instance.public_ip
#     }
#
#     inline = [
#       "sudo yum install python3.11-devel python3.11-pip -y",
#       "sudo pip3.11 install ansible botocore boto3 python-jenkins hvac",
#       "ansible-pull -i localhost, -U https://github.com/s-devops-i3/expense-ansible get-secrets.yml -e env=${var.env} -e role_name=${var.component} -e vault_token=${var.vault_token}",
#       "ansible-pull -i localhost, -U https://github.com/s-devops-i3/expense-ansible expense.yml -e env=${var.env} -e role_name=${var.component} -e @app.json -e @secrets.json",
#       "rm -rf ~/app.json ~/secrets.json"
#
#     ]
#   }
# }

resource "aws_route53_record" "record" {
  name    = "${var.component}-${var.env}"
  type    = "A"
  zone_id = var.zone_id
  records = [aws_instance.instance.private_ip]
  ttl     = 30
}