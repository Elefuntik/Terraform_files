provider "aws" {
 # access_key = "xxxxxxxxxxxxxxxxxxx"
 # secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  region     = "eu-central-1"
}

resource "aws_instance" "amazon_linux_server1" {
  ami                    = "ami-0a02ee601d742e89f"
  instance_type          = "t2.micro"
  count                  = 1  
  vpc_security_group_ids = [aws_security_group.allow_ssh_rdp_icmpv4.id]
  key_name               = "Frankfurt-key"
  root_block_device {
       volume_size = 10
    }
  tags = {
    Name  = "amazon_linux_serv01"
    Owner = "Ivan Dziarzhynski"
  }
}


resource "aws_instance" "amazon_linux_server2" {
  ami                    = "ami-0a02ee601d742e89f"
  instance_type          = "t2.micro"
  count                  = 1  
  vpc_security_group_ids = [aws_security_group.allow_ssh_rdp_icmpv4.id]  
  key_name               = "Frankfurt-key"
  root_block_device {
       volume_size = 10
    }
  tags = {
    Name  = "amazon_linux_serv02"
    Owner = "Ivan Dziarzhynski"
  }
}

resource "aws_security_group" "allow_ssh_rdp_icmpv4" {
  name        = "Remote connection Security Group (SSH, RDP, ICMPv4)"
  description = "Allow SSH, RDP, ICMPv4 inbound traffic"
  

  ingress {
    description = "Allow SSH Connection"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow RDP Connection"
    from_port   = 3389
    to_port     = 3389
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

    ingress {
    description = "Allow ICMPv4 (ping)"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_ssh_rdp_icmpv4"
  }
}