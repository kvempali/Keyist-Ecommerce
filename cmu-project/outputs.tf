output "control_plane_ip" {
  value = data.aws_eip.control_plane_eip.public_ip
}

output "worker_nodes_ip" {
  value = [for instance in data.aws_eip.worker_node_eips : instance.public_ip]
}

