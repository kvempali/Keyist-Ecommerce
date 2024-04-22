resource "aws_instance" "instance-1" {
  ami             = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance-type
  subnet_id       = aws_subnet.pub-sub-1.id
  security_groups = [aws_security_group.sg.id]
  key_name        = var.key-name
  user_data       = filebase64("scripts/user-data.sh")
  tags = {
    Name = "Instance 1"
  }
}

resource "aws_instance" "instance-2" {
  ami             = data.aws_ami.latest_ubuntu.id
  instance_type   = var.instance-type
  subnet_id       = aws_subnet.pub-sub-2.id
  security_groups = [aws_security_group.sg.id]
  key_name        = var.key-name
  user_data       = filebase64("scripts/user-data.sh")

  tags = {
    Name = "Instance 2"
  }

}

/* Need a tools server*/

/*K8s Master/Node Setup (three boxes)*/
