resource "aws_db_instance" "rds-1" {
  allocated_storage      = 10
  db_name                = "mydb"
  engine                 = "mysql"
  engine_version         = "8.0.36"
  instance_class         = "db.t3.micro"
  username               = var.db-username
  password               = var.db-password
  parameter_group_name   = "default.mysql8.0"
  db_subnet_group_name   = aws_db_subnet_group.subnet-grp.name
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  skip_final_snapshot    = true
  publicly_accessible = true
  allow_major_version_upgrade = true
  apply_immediately = true
}

resource "aws_db_subnet_group" "subnet-grp" {
  name       = var.db-subnet
  subnet_ids = [aws_subnet.kubeadm_demo_subnet.id, aws_subnet.kubeadm_demo_subnet2.id] # Adjust this to include your desired subnets
}


resource "aws_security_group" "db-sg" {
  name        = var.db-sg-name
  description = "Allow tls for inbound traffic"
  vpc_id      = aws_vpc.kubeadm_demo_vpc.id

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [
    #  aws_security_group.kubadm_demo_sg_common.id,
      # aws_security_group.kubeadm_demo_sg_flannel.id,
    #  aws_security_group.kubeadm_demo_sg_control_plane.id,
    #]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.db-sg-name
  }
}

resource "null_resource" "example" {
  depends_on = [aws_db_instance.rds-1]
  provisioner "local-exec" {
    command = "/bin/bash ./k8s_nodes_pre_steps.sh"
   }
 }

