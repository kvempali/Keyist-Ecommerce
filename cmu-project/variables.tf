variable "vpc_cidr_block" {
  type        = string
  description = "vpc default cidr block"
  default     = "10.0.0.0/16"
}

# variable "ubuntu_ami" {
#   type        = string
#   description = "the AMI ID of our linux instance"
#   # default = "ami-007020fd9c84e18c7"
# }

variable "worker_nodes_count" {
  type        = number
  description = "the total number of worker nodes"
  default     = 2
}


variable "keypair_name" {
  type        = string
  description = "the name of our keypair"
  default     = "kubeadm_demo"
}

variable "db-username" {
  description = "Username for db instance"
  sensitive   = true
}

variable "db-password" {
  description = "Password for db instance"
  sensitive   = true
}

variable "instance-type" {
  description = "Value for instance type"
}

variable "availability-zone-1" {
  description = "Defined AZ 1"
}

variable "availability-zone-2" {
  description = "Defined AZ 2"
}

variable "ec2-volume-type" {
  description = "EC2 Volume Type"
}

variable "ec2-volume-size" {
  description = "EC2 Volume Size"
}

variable "region" {
  description = "AWS Region"
}

variable "db-sg-name" {
  description = "Name for db security group"
}

variable "db-subnet" {
  description = "Name for db subnet group"
}