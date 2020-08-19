provider "aws" {
	region = "us-east-1"
}

resource "aws_vpc" "terraform-vpc" {
	cidr_block = "10.0.0.0/16"
	instance_tenancy = "default"
	enable_dns_support = "true"
	enable_dns_hostnames = "true"
	enable_classiclink = "false"
	tags = {
		Name = "terraform"
	}
}

resource "aws_subnet" "public-1" {
	vpc_id = aws_vpc.terraform-vpc.id
	cidr_block ="10.0.1.0/24"
	map_public_ip_on_launch = "true"
	tags = {
		Name = "public"
	}
}

resource "aws_subnet" "private-1" {
	vpc_id = aws_vpc.terraform-vpc.id
	cidr_block ="10.0.100.0/24"
	map_public_ip_on_launch = "false"
	tags = {
		Name = "private"
	}
}

resource "aws_internet_gateway" "gw" {
	vpc_id = aws_vpc.terraform-vpc.id
	tags = {
		Name = "internet-gateway"
	}
}

resource "aws_route_table" "rt1" {
	vpc_id = aws_vpc.terraform-vpc.id
	route {
		cidr_block = "0.0.0.0/0"
		gateway_id = aws_internet_gateway.gw.id
	}
	tags = {
		Name = "Default"
	}
}

resource "aws_route_table_association" "association-subnet" {
	subnet_id = aws_subnet.public-1.id
	route_table_id = aws_route_table.rt1.id
}

resource "aws_instance" "ansible_master" {
	ami = "ami-030ff268bd7b4e8b5"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.websg.id]
	subnet_id = aws_subnet.public-1.id
	
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			password = "thinknyx@123"
			host = self.public_ip
		}
		
		inline = [
			"hostnamectl set-hostname ansible_master",
			"yum install -y epel-release",
			"yum install -y ansible",
			"mv /etc/ansible/hosts /etc/ansible/hosts_old",
			"echo '[nodes]' > /etc/ansible/hosts"
		]
	}

	tags = {
		Name = "Ansible-Master-Kul"
		Training = "IBM-Adv-DevOps"
	}
}

resource "aws_instance" "ansible_node" {
	ami = "ami-030ff268bd7b4e8b5"
	instance_type = "t2.micro"
	vpc_security_group_ids = [aws_security_group.websg.id]
	subnet_id = aws_subnet.public-1.id
	
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			password = "thinknyx@123"
			host = self.public_ip
		}
		
		inline = [
			"hostnamectl set-hostname ansible_node"
		]
	}
	
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			password = "thinknyx@123"
			host = aws_instance.ansible_master.public_ip
		}
		
		inline = [
			"echo '${self.private_ip}' >> /etc/ansible/hosts"
		]
	}

	tags = {
		Name = "Ansible-Node-Kul"
		Training = "IBM-Adv-DevOps"
	}
}

resource "aws_security_group" "websg" {
	name = "security_group_for_web_server"
	vpc_id = aws_vpc.terraform-vpc.id
	ingress {
		from_port = 80
		to_port = 80
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
}

output "vpc-id" {
	value = aws_vpc.terraform-vpc.id
}

output "vpc-publicsubnet" {
	value = aws_subnet.public-1.cidr_block
}

output "vpc-publicsubnet-id" {
	value = aws_subnet.public-1.id
}

output "vpc-privatesubnet" {
	value = aws_subnet.private-1.cidr_block
}

output "vpc-privatesubnet-id" {
	value = aws_subnet.private-1.id
}

output "ansible_master_public_ip" {
	value = aws_instance.ansible_master.public_ip
}

output "ansible_master_private_ip" {
	value = aws_instance.ansible_master.private_ip
}

output "ansible_node_public_ip" {
	value = aws_instance.ansible_node.public_ip
}

output "ansible_node_private_ip" {
	value = aws_instance.ansible_node.private_ip
}