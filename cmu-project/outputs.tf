# output "dns-name" {
#   value = aws_lb.test.dns_name
# }

output "latest_ubuntu_ami_id" {
  value = data.aws_ami.latest_ubuntu.id
  description = "The latest Ubuntu 22.04 AMI ID"
}

output "instance-1-public-ip" {
  value = "Instance 1 public IP is: ${aws_instance.instance-1.public_ip}"
}

output "instance-2-public-ip" {
  value = "Instance 2 public IP is: ${aws_instance.instance-2.public_ip}"
}

output "keyname" {
  value = var.key-name
}