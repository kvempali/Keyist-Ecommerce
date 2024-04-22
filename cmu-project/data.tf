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