provider "aws" {
 # access_key = "xxxxxxxxxxxxxxxxxxx"
 # secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  region     = "eu-central-1"
}


resource "aws_instance" "WebServer-1" {
    ami                         = "ami-05ca073a83ad2f28c"
    availability_zone           = "eu-central-1a"    
    instance_type               = "t2.micro"    
    key_name                    = "Frankfurt-key"    
    vpc_security_group_ids      = [aws_security_group.webservers_security_group.id] 
    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags = {
        Name = "WebServer-1"
        Owner = "Ivan Dziarzhynski"
    }
    user_data = file("e:/Git/Linux-UNIX/Bash_Scripts/Install_simple_web_server1.sh")
}

resource "aws_instance" "WebServer-2" {
    ami                         = "ami-05ca073a83ad2f28c"
    availability_zone           = "eu-central-1b"    
    instance_type               = "t2.micro"    
    key_name                    = "Frankfurt-key"    
    vpc_security_group_ids      = [aws_security_group.webservers_security_group.id] 
    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags = {
        Name = "WebServer-2"
        Owner = "Ivan Dziarzhynski"
    }
    user_data = file("e:/Git/Linux-UNIX/Bash_Scripts/Install_simple_web_server2.sh")
}

resource "aws_instance" "WebServer-3" {
    ami                         = "ami-05ca073a83ad2f28c"
    availability_zone           = "eu-central-1c"    
    instance_type               = "t2.micro"    
    key_name                    = "Frankfurt-key"    
    vpc_security_group_ids      = [aws_security_group.webservers_security_group.id] 
    root_block_device {
        volume_type           = "gp2"
        volume_size           = 8
        delete_on_termination = true
    }

    tags = {
        Name = "WebServer-3"
        Owner = "Ivan Dziarzhynski"
    }
    user_data = file("e:/Git/Linux-UNIX/Bash_Scripts/Install_simple_web_server3.sh")
}



resource "aws_security_group" "webservers_security_group" {
    name        = "WebServers Security Group"
    description = "Allow HTTP. HTTPS for web and SSH, RDP, ICMPv4 for remote access"
    
    ingress {
        description     = "Allow HTTP"
        from_port       = 80
        to_port         = 80
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }

    ingress {
        description     = "Allow SSH Connection" 
        from_port       = 22
        to_port         = 22
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }

    ingress {
        description     = "Allow RDP Connection"
        from_port       = 3389
        to_port         = 3389
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }

    ingress {
        description     = "Allow HTTPS"
        from_port       = 443
        to_port         = 443
        protocol        = "tcp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }

    ingress {
        description     = "Allow ICMPv4 (ping)"
        from_port       = -1
        to_port         = -1
        protocol        = "icmp"
        cidr_blocks     = ["0.0.0.0/0"]
        ipv6_cidr_blocks     = ["::/0"]
    }


    egress {
        from_port       = 0
        to_port         = 0
        protocol        = "-1"
        cidr_blocks     = ["0.0.0.0/0"]
    }

    tags = {
        Name = "WebServers"
    }
}