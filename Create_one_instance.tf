provider "aws" {
# access_key = "xxxxxxxxxxxxxxxxxxx"
# secret_key = "xxxxxxxxxxxxxxxxxxxxxxxx"
  region     = "eu-central-1"
}

resource "aws_instance" "amazon_linux_server" {                                 # создание нового ресурса "aws_instance" с названием "amazon_linux_server"
  ami                = "ami-0a02ee601d742e89f"                                  # значение ami (amazon machune instance) (ISO-образ) 
  instance_type      = "t2.micro"                                               # тип инстанса (железо)
  count              = 1                                                        # количество инстансов
  # security_groups    = ["allow_ssh_rdp_icmpv4"]                               # подключение к существующей группе безопасности
  vpc_security_group_ids = [aws_security_group.allow_ssh_rdp_icmpv4.id]         # подключение к создаваемой группе безопасности
  key_name           = "Frankfurt-key"                                          # имя существующего клча для подключения к инстансу
  root_block_device {                                                           # диск, создаваемый с инстансом
       volume_size = 10                                                         # объем
       volume_type = "gp2"
    } 
  tags = {                                                                      # теги инстанса
    Name  = "amazon_linux_serv01"                                               # имя
    Owner = "Ivan Dziarzhynski"                                                 # владелец
  }
  user_data = file("E:/Git/Linux-UNIX/Bash_Scripts/Install_soft.sh")            # исполняемые данные после создания инстанса (может быть скрипт на bash или ps)
}

resource "aws_security_group" "allow_ssh_rdp_icmpv4" {                          # создание нового ресурса "aws_security_group" (группа безопасности) с названием "allow_ssh_rdp_icmpv4"
  name        = "Remote connection Security Group (SSH, RDP, ICMPv4)"           # имя
  description = "Allow SSH, RDP, ICMPv4 inbound traffic"                        # описание
  

  ingress {                                                                     # правило входящего соединения
    description = "Allow SSH Connection"                                        # описание входящего соединения
    from_port   = 22                                                            # с какого порта входящее соединение
    to_port     = 22                                                            # на какой порт входящее соединение
    protocol    = "TCP"                                                         # протокол передачи
    cidr_blocks = ["0.0.0.0/0"]                                                 # с каких IP - адресов возможно соединение (в данном случае с любого)
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

  egress {                                                                   # правило исходящего соединения                   (в данном блоке открыт весь исходящий траффик)
    from_port   = 0                                                          # с каких портов (со всех)
    to_port     = 0                                                          # на какие порты (со всех)
    protocol    = "-1"                                                       # протокол передачи (тут конкретный отсутствует)
    cidr_blocks = ["0.0.0.0/0"]                                              # на какие IP-адреса исходящее соединения
  }

  tags = {                                                                   # тег
    Name = "allow_ssh_rdp_icmpv4"                                            # имя
  }
}
