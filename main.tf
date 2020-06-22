data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}


resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "kube"
  }
}

resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.vpc_cidr
  tags = {
    Name = "kube"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "kube"
  }
}


resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = var.all_cidr
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "kube"
  }
}

resource "aws_route_table_association" "rt-assoc" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}


resource "aws_security_group" "kube" {
  name   = "kube-sg"
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "kube"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group_rule" "allow_ssh" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.kube.id
  cidr_blocks       = [local.workstation-external-cidr]
}

resource "aws_security_group_rule" "allow_icmp" {
  type              = "ingress"
  from_port         = -1
  to_port           = -1
  protocol          = "icmp"
  security_group_id = aws_security_group.kube.id
  cidr_blocks       = [var.all_cidr]
}

resource "aws_security_group_rule" "allow_http_mgr" {
  type              = "ingress"
  from_port         = 6443
  to_port           = 6443
  protocol          = "tcp"
  security_group_id = aws_security_group.kube.id
  cidr_blocks       = [var.all_cidr]
}



resource "aws_security_group_rule" "allow_outgoing" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.kube.id
  cidr_blocks       = [var.all_cidr]
}

resource "aws_security_group_rule" "allow_access_from_this_security_group" {
  type                     = "ingress"
  from_port                = -1
  to_port                  = -1
  protocol                 = "-1"
  security_group_id        = aws_security_group.kube.id
  source_security_group_id = aws_security_group.kube.id
}


resource "aws_key_pair" "ssh" {
  count      = var.aws_key_pair_name == null ? 1 : 0
  key_name   = "${var.owner}-${var.project}"
  public_key = file(var.ssh_public_key_path)
}


resource "aws_instance" "master" {
  count                       = var.mon_count
  ami                         = var.centos
  instance_type               = var.mon_instance_type
  vpc_security_group_ids      = [aws_security_group.kube.id]
  key_name                    = var.aws_key_pair_name == null ? aws_key_pair.ssh.0.key_name : var.aws_key_pair_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "master-${count.index}"
  }
}

resource "aws_instance" "worker" {
  count                       = var.osd_count
  ami                         = var.centos
  instance_type               = var.osd_instance_type
  vpc_security_group_ids      = [aws_security_group.kube.id]
  key_name                    = var.aws_key_pair_name == null ? aws_key_pair.ssh.0.key_name : var.aws_key_pair_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "worker-${count.index}"
  }
}

resource "aws_instance" "client" {
  count                       = var.client_count
  ami                         = var.centos
  instance_type               = var.client_instance_type
  vpc_security_group_ids      = [aws_security_group.kube.id]
  key_name                    = var.aws_key_pair_name == null ? aws_key_pair.ssh.0.key_name : var.aws_key_pair_name
  subnet_id                   = aws_subnet.subnet.id
  associate_public_ip_address = true
  tags = {
    Name = "client-${count.index}"
  }
}
