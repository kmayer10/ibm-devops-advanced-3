EC2 1 (server 1)
	yum install -y epel-release
	yum install -y ansible
EC2 2 (Server 2)
	private_ip to /etc/ansible/hosts (Server 1)
	
Both Systems should run on same AZ or VPC
SG
	All Outbound Open
	Only 22 SSH Inbound Open
