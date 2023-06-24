locals {
  ansible_ubuntu_user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt-add-repository ppa:ansible/ansible
sudo apt update -y
sudo apt install ansible -y
sudo hostnamectl set-hostname Ansible-Node
sudo cd /home/ubuntu/.ssh/
sudo chmod -R 700 /home/ubuntu/.ssh
sudo chown -R ubuntu:ubuntu /home/ubuntu/.ssh
echo "${tls_private_key.managed.private_key_pem}" >> /home/ubuntu/.ssh/ansible_key
sudo chmod 400 ansible_key
sudo bash -c ' echo "StrictHostKeyChecking No" >> /etc/ssh/ssh_config'
cat <<EOT>> /etc/ansible/hosts
localhost ansible_connection=local
[managed_nodes]
${data.aws_instance.managed-node3.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/ansible_key
${data.aws_instance.managed-node4.private_ip} ansible_user=ubuntu ansible_ssh_private_key_file=/home/ubuntu/.ssh/ansible_key
EOT
EOF
}


