terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    ansible = {
      source  = "ansible/ansible"
      version = "1.1.0"
    }

  }
}

provider "aws" {
  region = var.region
}

resource "aws_vpc" "kubeadm_demo_vpc" {

  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    # NOTE: very important to use an uppercase N to set the name in the console
    Name                               = "kubeadm_demo_vpc"
    "kubernetes.io/cluster/kubernetes" = "owned"
  }

}


resource "aws_subnet" "kubeadm_demo_subnet" {
  vpc_id                  = aws_vpc.kubeadm_demo_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "kubadm_demo_public_subnet"
  }

}

resource "aws_subnet" "kubeadm_demo_subnet2" {
  vpc_id                  = aws_vpc.kubeadm_demo_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b" # Specify AZ for subnet2
  map_public_ip_on_launch = true

  tags = {
    Name = "Subnet in AZ 2"
  }
}

resource "aws_internet_gateway" "kubeadm_demo_igw" {
  vpc_id = aws_vpc.kubeadm_demo_vpc.id

  tags = {
    Name = "Kubeadm Demo Internet GW"
  }

}

resource "aws_route_table" "kubeadm_demo_routetable" {
  vpc_id = aws_vpc.kubeadm_demo_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.kubeadm_demo_igw.id
  }

  tags = {
    Name = "kubeadm Demo IGW route table"
  }

}

resource "aws_route_table_association" "kubeadm_demo_route_association" {
  subnet_id      = aws_subnet.kubeadm_demo_subnet.id
  route_table_id = aws_route_table.kubeadm_demo_routetable.id
}

resource "aws_route_table_association" "kubeadm_demo_route_association2" {
  subnet_id      = aws_subnet.kubeadm_demo_subnet2.id
  route_table_id = aws_route_table.kubeadm_demo_routetable.id
}

resource "aws_security_group" "kubeadm_demo_sg_flannel" {
  name   = "flannel-overlay-backend"
  vpc_id = aws_vpc.kubeadm_demo_vpc.id
  tags = {
    Name = "Flannel Overlay backend"
  }

  ingress {
    description = "flannel overlay backend"
    protocol    = "udp"
    from_port   = 8285
    to_port     = 8285
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "flannel vxlan backend"
    protocol    = "udp"
    from_port   = 8472
    to_port     = 8472
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_security_group" "kubadm_demo_sg_common" {
  name   = "common-ports"
  vpc_id = aws_vpc.kubeadm_demo_vpc.id
  tags = {
    Name = "common ports"
  }

  ingress {
    description = "Allow SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


}
resource "aws_security_group" "kubeadm_demo_sg_control_plane" {
  name   = "kubeadm-control-plane security group"
  vpc_id = aws_vpc.kubeadm_demo_vpc.id
  ingress {
    description = "API Server"
    protocol    = "tcp"
    from_port   = 6443
    to_port     = 6443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kubelet API"
    protocol    = "tcp"
    from_port   = 2379
    to_port     = 2380
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "etcd server client API"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Scheduler"
    protocol    = "tcp"
    from_port   = 10259
    to_port     = 10259
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Kube Contoller Manager"
    protocol    = "tcp"
    from_port   = 10257
    to_port     = 10257
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Control Plane SG"
  }
}


resource "aws_security_group" "kubeadm_demo_sg_worker_nodes" {
  name   = "kubeadm-worker-node security group"
  vpc_id = aws_vpc.kubeadm_demo_vpc.id
  ingress {
    description = "kubelet API"
    protocol    = "tcp"
    from_port   = 10250
    to_port     = 10250
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "NodePort services"
    protocol    = "tcp"
    from_port   = 30000
    to_port     = 32767
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Worker Nodes SG"
  }

}

resource "tls_private_key" "kubadm_demo_private_key" {

  algorithm = "RSA"
  rsa_bits  = 4096

  provisioner "local-exec" { # Create a "pubkey.pem" to your computer!!
    command = "echo '${self.public_key_pem}' > ./pubkey.pem"
  }
}

resource "aws_key_pair" "kubeadm_demo_key_pair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.kubadm_demo_private_key.public_key_openssh

  provisioner "local-exec" { # Create a "myKey.pem" to your computer!!
    command = "echo '${tls_private_key.kubadm_demo_private_key.private_key_pem}' > ./private-key.pem" 
  }
}



resource "aws_instance" "kubeadm_demo_control_plane" {
  ami               = data.aws_ami.latest_ubuntu.id
  instance_type     = var.instance-type
  availability_zone = var.availability-zone-1
  key_name          = aws_key_pair.kubeadm_demo_key_pair.key_name
  #associate_public_ip_address = true
  subnet_id = aws_subnet.kubeadm_demo_subnet.id
  security_groups = [
    aws_security_group.kubadm_demo_sg_common.id,
    aws_security_group.kubeadm_demo_sg_flannel.id,
    aws_security_group.kubeadm_demo_sg_control_plane.id,
    aws_security_group.db-sg.id,
    aws_security_group.sonarqube_sg.id,
  ]
  root_block_device {
    volume_type = var.ec2-volume-type
    volume_size = var.ec2-volume-size
  }

  # Associate with the pre-allocated Elastic IP
  #network_interface {
  #  network_interface_id = data.aws_eip.control_plane_eip.network_interface_id  # Use the network interface ID of the Elastic IP
  #  device_index = 0 # Set this to 0 if it's the primary network interface
  #}

  tags = {
    Name = "Kubeadm Master"
    Role = "Control plane node"
  }

  provisioner "local-exec" {
    command = "echo 'master ${data.aws_eip.control_plane_eip.public_ip}' >> ./files/hosts"
  }
}

resource "aws_instance" "kubeadm_demo_worker_nodes" {
  count         = var.worker_nodes_count
  ami           = data.aws_ami.latest_ubuntu.id
  instance_type = var.instance-type
  key_name      = aws_key_pair.kubeadm_demo_key_pair.key_name
  # associate_public_ip_address = false
  // Determine subnet ID based on the index of the worker node
  subnet_id = count.index % 2 == 0 ? aws_subnet.kubeadm_demo_subnet.id : aws_subnet.kubeadm_demo_subnet2.id

  security_groups = [
    aws_security_group.kubeadm_demo_sg_flannel.id,
    aws_security_group.kubadm_demo_sg_common.id,
    aws_security_group.kubeadm_demo_sg_worker_nodes.id,
    aws_security_group.db-sg.id,
    aws_security_group.sonarqube_sg.id,
  ]
  root_block_device {
    volume_type = var.ec2-volume-type
    volume_size = var.ec2-volume-size
  }

  # Associate with the pre-allocated Elastic IP
  #network_interface {
  #  network_interface_id = data.aws_eip.worker_node_eips[count.index].id
  #  device_index         = 0
  #}

  tags = {
    Name = "Kubeadm Worker ${count.index}"
    Role = "Worker node"
  }

  provisioner "local-exec" {
    command = "echo 'worker-${count.index} ${data.aws_eip.worker_node_eips[count.index].public_ip}' >> ./files/hosts"
  }

  # provisioner "remote-exec" {
  #   inline = ["echo ${aws_eip.elastic_ips[count.index + 1].public_ip} > ~/eip.txt"]  # Output Elastic IP to a file
  # }
}

resource "ansible_host" "kubadm_demo_control_plane_host" {
  depends_on = [
    aws_instance.kubeadm_demo_control_plane
  ]
  name   = "control_plane"
  groups = ["master"]
  variables = {
    ansible_user                 = "ubuntu"
    #ansible_host                 = aws_instance.kubeadm_demo_control_plane.public_ip
    ansible_host = data.aws_eip.control_plane_eip.public_ip
    ansible_ssh_private_key_file = "./private-key.pem"
    node_hostname                = "master"
  }
}

resource "ansible_host" "kubadm_demo_worker_nodes_host" {
  depends_on = [
    aws_instance.kubeadm_demo_worker_nodes
  ]
  count  = 2
  name   = "worker-${count.index}"
  groups = ["workers"]
  variables = {
    node_hostname                = "worker-${count.index}"
    ansible_user                 = "ubuntu"
    #ansible_host                 = aws_instance.kubeadm_demo_worker_nodes[count.index].public_ip
    ansible_host = data.aws_eip.worker_node_eips[count.index].public_ip
    ansible_ssh_private_key_file = "./private-key.pem"
  }
}

#resource "aws_eip" "control_plane_eip" {
#  instance = aws_instance.kubeadm_demo_control_plane.id
#}

#resource "aws_eip" "worker_nodes_eip" {
#  count = var.worker_nodes_count
#  instance = aws_instance.kubeadm_demo_worker_nodes[count.index].id
#}


resource "aws_eip_association" "control_plane_eip_association" {
  instance_id   = aws_instance.kubeadm_demo_control_plane.id
  allocation_id = data.aws_eip.control_plane_eip.id
}

resource "aws_eip_association" "worker_nodes_eip_association" {
  count         = var.worker_nodes_count
  instance_id   = aws_instance.kubeadm_demo_worker_nodes[count.index].id
  allocation_id = data.aws_eip.worker_node_eips[count.index].id

  provisioner "local-exec" {
  command = "/bin/bash ./post_steps.sh"
  when    = destroy
  }

}

#resource "null_resource" "example" {
#  provisioner "local-exec" {
#    command = "/bin/bash ./post_steps.sh"
#    when    = "destroy"
#   }
# }



