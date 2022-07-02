data "aws_ami" "ubuntu-jammy-x86_64" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

data "aws_ami" "ubuntu-jammy-arm64" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["099720109477"] # Canonical
}

variable ssh_key {
  default = "vockey"
}

resource "aws_instance" "kube-master" {
  ami = data.aws_ami.ubuntu-jammy-x86_64.id
  instance_type = "t3.medium"

  count = 3

  vpc_security_group_ids = [
    aws_security_group.egress-all-all.id,
    aws_security_group.ingress-all-all.id,
    aws_security_group.ingress-all-ssh.id,
    aws_security_group.ingress-all-http.id,
    aws_security_group.ingress-all-kubeapi.id,
  ]

  user_data = templatefile("${path.module}/templates/init_kube-master.tftpl", { PLACEHOLDER = "placeholder" })

  key_name = "${var.ssh_key}"

  tags = {
    Name = "kube-master-${count.index}"
  }
}

resource "aws_instance" "kube-worker-x86_64" {
  ami = data.aws_ami.ubuntu-jammy-x86_64.id
  instance_type = "t3.medium"

  count = 2

  vpc_security_group_ids = [
    aws_security_group.egress-all-all.id,
    aws_security_group.ingress-all-all.id,
    aws_security_group.ingress-all-ssh.id,
    aws_security_group.ingress-all-http.id,
    aws_security_group.ingress-all-kubeapi.id,
  ]

  user_data = templatefile("${path.module}/templates/init_kube-worker.tftpl", { PLACEHOLDER = "placeholder" })

  key_name = "${var.ssh_key}"

  tags = {
    Name = "kube-worker-x86_64-${count.index}"
  }
}

resource "aws_instance" "kube-worker-arm64" {
  ami = data.aws_ami.ubuntu-jammy-arm64.id
  instance_type = "a1.large"

  count = 3

  vpc_security_group_ids = [
    aws_security_group.egress-all-all.id,
    aws_security_group.ingress-all-all.id,
    aws_security_group.ingress-all-ssh.id,
    aws_security_group.ingress-all-http.id,
    aws_security_group.ingress-all-kubeapi.id,
  ]

  user_data = templatefile("${path.module}/templates/init_kube-worker.tftpl", { PLACEHOLDER = "placeholder" })

  key_name = "${var.ssh_key}"

  tags = {
    Name = "kube-worker-arm64-${count.index}"
  }
}

# generate inventory file for Ansible
resource "local_file" "hosts" {
  content = templatefile("${path.module}/templates/hosts.tftpl",
    {
      kube-masters = aws_instance.kube-master.*.public_ip
      kube-workers-x86_64 = aws_instance.kube-worker-x86_64.*.public_ip
      kube-workers-arm64 = aws_instance.kube-worker-arm64.*.public_ip
    }
  )
  filename = "../ansible/inventory"
}
