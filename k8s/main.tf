provider "aws" {
	region = "us-east-1"
}

variable "node_name" {
	default = "demo"
}

variable "master_name" {
	default = "demo"
}

variable "sg_name" {
	default = "demo"
}

resource "aws_instance" "ansible_master" {
	ami = "ami-030ff268bd7b4e8b5"
	instance_type = "t2.medium"
	
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
			"yum install -y ansible git",
			"git clone https://github.com/kmayer10/ibm-devops-advanced-3.git /root/devops",
			"cp -R /root/devops/ansible/roles/* /etc/ansible/roles/,
			"mv /etc/ansible/ansible.cfg /etc/ansible/ansible.cfg_old",
			"cp -R /root/devops/ansible/ansible.cfg /etc/ansible/ansible.cfg,
			"mv /etc/ansible/hosts /etc/ansible/hosts_old",
			"echo '[master]' > /etc/ansible/hosts",
			"echo '${self.private_ip}' >> /etc/ansible/hosts",
			"echo '[nodes]' >> /etc/ansible/hosts"
		]
	}

	tags = {
		Name = var.master_name
		Training = "IBM-Adv-DevOps"
	}
}

resource "aws_instance" "ansible_node" {
	ami = "ami-030ff268bd7b4e8b5"
	instance_type = "t2.micro"
	
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			password = "thinknyx@123"
			host = self.public_ip
		}
		
		inline = [
			"hostnamectl set-hostname ansible_node",
			"echo '${self.private_ip} ansible_node' >> /etc/hosts",
			"echo '${aws_instance.ansible_master.private_ip} ansible_master' >> /etc/hosts"
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
			"echo '${self.private_ip}' >> /etc/ansible/hosts",
			"echo '${self.private_ip} ansible_node' >> /etc/hosts",
			"echo '${aws_instance.ansible_master.private_ip} ansible_master' >> /etc/hosts"
		]
	}

	tags = {
		Name = var.node_name
		Training = "IBM-Adv-DevOps"
	}
}

resource "aws_security_group" "websg" {
	name = var.sg_name
	ingress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	tags = {
		Name = "ibm-devops-advanced"
	}
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