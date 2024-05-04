resource "aws_instance" "sonar_server" {
  ami               = data.aws_ami.latest_ubuntu.id
  instance_type     = var.instance-type
  availability_zone = var.availability-zone-1
  key_name          = aws_key_pair.kubeadm_demo_key_pair.key_name
  associate_public_ip_address = true
  user_data = file("./files/sonar_script.sh")
  subnet_id = aws_subnet.kubeadm_demo_subnet.id
  security_groups = [
    aws_security_group.sonarqube_sg.id
  ]
  root_block_device {
    volume_type = var.ec2-volume-type
    volume_size = "15"
  }

  tags = {
    Name = "Sonarqube Server"
  }
}


resource "aws_security_group" "sonarqube_sg" {
  name   = "sonarqube security group"
  vpc_id = aws_vpc.kubeadm_demo_vpc.id
  ingress {
    description = "sonarqube"
    protocol    = "tcp"
    from_port   = 9000
    to_port     = 9000
    cidr_blocks = ["0.0.0.0/0"]
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

  tags = {
    Name = "Allow Sonar"
  }

}

output "sonar_public_ip" {
  value = aws_instance.sonar_server.public_ip
}