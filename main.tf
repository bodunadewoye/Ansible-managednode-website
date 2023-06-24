# CREATE KEY PAIR
resource "aws_key_pair" "olukey" {
  key_name   = "capkey"
  public_key = file("~/.ssh/capkey.pub")
}

#CREAT ANSIBLE-NODE SECURITY GROUP
resource "aws_security_group" "ansible-node-sg" {
  name        = "ansible-node-sg"
  description = "Allow SSH inbound traffic"
 

  ingress {
    description      = "ssh access"
    from_port        = var.ssh_port 
    to_port          = var.ssh_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "ansible-node-sg"
  }
}


resource "aws_instance" "ansible-node" {
  ami                                = var.ami-ubuntu  
  instance_type                      = "t2.micro"
  key_name                           = "capkey"
  associate_public_ip_address        = true
  vpc_security_group_ids             = [aws_security_group.ansible-node-sg.id]


  user_data = local.ansible_ubuntu_user_data

  tags = {
    Name = "ansible-node"
  }
}

# CREATE KEY PAIR TO SPIN FOR THE CONTROL NODES
resource "tls_private_key" "managed" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "managed_priv" {
  filename        = "control.pem"
  content         = tls_private_key.managed.private_key_pem 
  file_permission = "600"
}

resource "aws_key_pair" "managed_pub" {
  key_name   = "control"
  public_key = tls_private_key.managed.public_key_openssh 
}

#CREAT ANSIBLE-NODE SECURITY GROUP
resource "aws_security_group" "managed-node-sg" {
  name        = "managed-node-sg"
  description = "Allow SSH & HTTP inbound traffic"
 

  ingress {
    description      = "ssh access"
    from_port        = var.ssh_port 
    to_port          = var.ssh_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  ingress {
    description      = "http access"
    from_port        = 80 
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }


  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "managed-node-sg"
  }
}


#CREATE MANAGED NODE 1
resource "aws_instance" "managed-node3" {
  ami                                = var.ami-ubuntu
  instance_type                      = "t2.micro"
  key_name                           = aws_key_pair.managed_pub.key_name 
  associate_public_ip_address        = true
  vpc_security_group_ids             = [aws_security_group.managed-node-sg.id]

  tags = {
    Name = "managed-node-server3"
  }
}

data "aws_instance" "managed-node3" {
  filter {
    name   = "tag:Name"
    values = ["managed-node-server3"]
  }
  depends_on = [aws_instance.managed-node3]
}


#CREATE MANAGED NODE 2
resource "aws_instance" "managed-node4" {
  ami                                = var.ami-ubuntu
  instance_type                      = "t2.micro"
  key_name                           = aws_key_pair.managed_pub.key_name 
  associate_public_ip_address        = true
  vpc_security_group_ids             = [aws_security_group.managed-node-sg.id]

  tags = {
    Name = "managed-node-server4"
  }
}

data "aws_instance" "managed-node4" {
  filter {
    name   = "tag:Name"
    values = ["managed-node-server4"]
  }
  depends_on = [aws_instance.managed-node4]
}