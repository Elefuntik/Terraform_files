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
    vpc_security_group_ids      = [aws_security_group.webservers_security_group.id, aws_security_group.allow_ssh_rdp_icmpv4.id] 
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
    description = "Allow HTTP, HTTPS protocols"
    
    ingress {
        description     = "Allow HTTP"
        from_port       = 80
        to_port         = 80
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


resource "aws_elb" "WebServers-LoadBalancer" {
    name                        = "WebServers-LoadBalancer"                                                                                      # Название балансировщика
    availability_zones          = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]                                                            # Зоны доступности
    security_groups             = [aws_security_group.webservers_security_group.id, aws_security_group.allow_ssh_rdp_icmpv4.id]                  # Группы безопасности (Firewall)
    instances                   = ["${aws_instance.WebServer-1.id}", "${aws_instance.WebServer-2.id}", "${aws_instance.WebServer-3.id}"]         # Инстансы EC2, которыми будет управлять load balancer
    cross_zone_load_balancing   = true                                                                                                           # Включение балансировки между инстансами в разных зонах
    idle_timeout                = 60                                                                                                             # 
    connection_draining         = true                                                                                                           #
    connection_draining_timeout = 300                                                                                                            #
    internal                    = false                                                                                                          #

    listener {                                                                                                  # слушатель (listener) портов и портоколов на балансирощике
        instance_port      = 80                                                                                 # порт инстанса (веб-сервера) на который перенаправляется траффик с балансировщика
        instance_protocol  = "http"                                                                             # протокол по которому перенаправляется траффик с балансировщика на инстанс (веб-сервер)
        lb_port            = 80                                                                                 # порт который слушает listener балансировщика и по которму приходит входящий траффик на него (балансировщик)
        lb_protocol        = "http"                                                                             # протокол на котором слушает listener балансировщика и по которму приходит входящий траффик на него (балансировщик)
        ssl_certificate_id = ""                                                                                 # id ssl-сертификата (если используется)
    }

    health_check {                                                                                              # проверка состояния инстансов
        healthy_threshold   = 10                                                                                # количество пройденных подряд проверок (health check) для того чтобы считать что инстанс работает
        unhealthy_threshold = 2                                                                                 # количество непройденных подряд проверок (health check) для того чтобы считать что инстанс не работает 
        interval            = 30                                                                                # время (интервал) для проверки (health check) (каждые 30 сек. будет выполняться health check)
        target              = "HTTP:80/index.html"                                                              # проверка состояния по протоколу http:80 путем открытия index.html
        timeout             = 5                                                                                 # время ожидания ответа при проверке (елси больше 5 сек. то проверка (health check) не проходит)
    }

    tags = {                                                                                                    # тег
        Project = "WebApp"                                                                                      
    }
} 
/* 
output "elb_instances" {                                                                                        
  value = ["${aws_elb.elb.instances}"]                                                                          
}

output "elb_public_dns_name" {                                                                                  
  value = ["${aws_elb.elb.dns_name}"]                                                                           
}
*/
