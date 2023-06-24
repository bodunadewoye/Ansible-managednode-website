output "ansible-node-sg-id" {
  value = aws_security_group.ansible-node-sg.id
}

output "ansible-managed-node3-private-ip" {
  value = aws_instance.managed-node3.private_ip
}

output "ansible-managed-node4-private-ip" {
  value = aws_instance.managed-node4.private_ip
}

output "ansible-managed-node3-public-ip" {
  value = aws_instance.managed-node3.public_ip
}

output "ansible-managed-node4-public-ip" {
  value = aws_instance.managed-node4.public_ip
}

output "ansible-node-public-ip" {
  value = aws_instance.ansible-node.public_ip
}

