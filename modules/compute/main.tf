data "aws_ami" "latest_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [var.bastion_sg_id]

  provisioner "local-exec" {
    command = "echo ${var.env} Bastion IP: ${self.public_ip} >> all_ips.txt"
  }

  tags = { Name = "${var.env}-bastion" }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.app_subnet_id
  vpc_security_group_ids = [var.app_sg_id]

  tags = { Name = "${var.env}-app" }
}
