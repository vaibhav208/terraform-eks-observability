data "aws_ami" "amazon_linux" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }
}

locals {
  plugins_txt = file("${path.module}/plugins.txt")
  casc_yaml   = file("${path.module}/casc.yaml")
}

resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Jenkins Security Group"
  vpc_id      = var.vpc_id

  ingress {
    description = "Jenkins UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = var.public_subnet_id

  key_name = "terraform-eks-observability-key"

  iam_instance_profile = var.instance_profile_name

  vpc_security_group_ids = [
    aws_security_group.jenkins.id
  ]

  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  user_data_replace_on_change = true

  user_data = templatefile(
    "${path.module}/userdata.sh.tpl",
    {
      plugins_txt = local.plugins_txt
      casc_yaml   = local.casc_yaml
    }
  )

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}

resource "aws_eip" "jenkins" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-jenkins-eip"
  }
}

resource "aws_eip_association" "jenkins" {
  instance_id   = aws_instance.jenkins.id
  allocation_id = aws_eip.jenkins.id
}