#Configruing a Provider
provider "aws" {
	region = "us-east-1"
}

variable "instance_count" {
	default = 1
}

variable "instance_count_1" {
	default = 1
}

variable "instance_type" {
	default = "t2.micro"
}

variable "availability_zone" {
	default = "us-east-1a"
}

resource "aws_instance" "centos_micro_1" {
	ami = "ami-030ff268bd7b4e8b5"
	instance_type = var.instance_type
	count = var.instance_count_1
	availability_zone = var.availability_zone
	
	security_groups = [
		aws_security_group.centos_security_group.name
	]
	
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			password = "thinknyx@123"
			host = aws_instance.centos_micro[count.index].public_ip
		}
		inline = [
			"echo '${self.private_ip}' >> /etc/hosts"
		]
	}
	
	tags = {
		training = "ibm-adv-devops"
		Name = "Kul-1"
	}
}

# Creating CENTOS 7 Server

resource "aws_instance" "centos_micro" {
	ami = "ami-030ff268bd7b4e8b5"
	instance_type = var.instance_type
	count = var.instance_count
	availability_zone = var.availability_zone
	
	security_groups = [
		aws_security_group.centos_security_group.name
	]
	
	# Remote working Provisioner
	provisioner "remote-exec" {
		connection {
			type = "ssh"
			user = "root"
			password = "thinknyx@123"
			host = self.public_ip
		}
		
		inline = [
			"hostnamectl set-hostname ibm-advanced-devops-demo",
			"yum install -y git java",
			"echo '${self.private_ip} ibm-advanced-devops-demo' >> /etc/hosts"
		]
	}
	
	provisioner "local-exec" {
		command = "echo ${self.public_ip} > host-ip"
	}
	
	tags = {
		training = "ibm-adv-devops"
		Name = "Kul"
	}
}

resource "aws_security_group" "centos_security_group" {
	name = "kul-sg"
	description = "this is for IBM Advanced DevOps Session"
	
	egress {
		from_port = 0
		to_port = 0
		protocol = "-1"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
		from_port = 22
		to_port = 22
		protocol = "tcp"
		cidr_blocks = ["0.0.0.0/0"]
	}
	
} 