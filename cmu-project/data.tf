# Define a data source to fetch the latest Ubuntu image ID
data "aws_ami" "latest_ubuntu" {
  # Search filters for the Ubuntu AMI
  most_recent = true             # Fetches the most recent image
  owners      = ["099720109477"] # Canonical's AWS account ID for Ubuntu

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"] # Adjust for your preferred Ubuntu version
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data block to retrieve pre-allocated Elastic IP for the control plane
data "aws_eip" "control_plane_eip" {
  filter {
    name   = "tag:Environment"
    values = ["control_plane_eip"]
  }
}

# Data block to retrieve Elastic IPs for worker nodes
data "aws_eip" "worker_node_eips" {
  count = var.worker_nodes_count
  filter {
    name   = "tag:Environment"
    values = ["worker_node_eip_${count.index + 1}"]
  }
}

# Data block to retrieve Elastic IPs for worker nodes
data "aws_eip" "sonarqube_eip" {
  count = var.worker_nodes_count
  filter {
    name   = "tag:Environment"
    values = ["sonarqube"]
  }
}
}