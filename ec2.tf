resource "aws_instance" "website_server" {                           # Criando a instância EC2
  ami                    = "ami-0ecb62995f68bb549"                   # AMI do Ubuntu 22.04 LTS
  instance_type          = "t3.micro"                                # Tipo de instância t3.micro
  key_name               = "sshec2"                                  # Chave SSH para a instância
  vpc_security_group_ids = [aws_security_group.website_sg.id]        # Associando o security group à instância
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name # Associando o profile à instância
  user_data              = file("user_data.sh")                       # Arquivo de script de inicialização

  tags = {
    Name        = "ec2-website"
    Provisioned = "Terraform"
    Cliente     = "David"
  }
}

# Security Group
resource "aws_security_group" "website_sg" {                    # Criando o security group
  name        = "website-sg"                                    # Nome do security group
  description = "Grupo de seguranca para o servidor de website" # Descricao do security group
  vpc_id      = "vpc-048a3aa91ab60dcb7"                         # VPC id

  tags = {
    Name        = "ec2-security-group"
    Provisioned = "Terraform"
    Cliente     = "David"
  }
}

# Regra de entrada para SSH
resource "aws_vpc_security_group_ingress_rule" "ssh_rule" {
  security_group_id = aws_security_group.website_sg.id # Associando o security group à instância
  cidr_ipv4         = "201.32.30.145/32"               # IP do meu computador
  from_port         = 22                               # Porta SSH
  ip_protocol       = "tcp"
  to_port           = 22 # Porta SSH

  tags = {
    Name        = "ec2-security-group"
    Provisioned = "Terraform"
    Cliente     = "David"
  }
}

# Regra de entrada para HTTP
resource "aws_vpc_security_group_ingress_rule" "http_rule" {
  security_group_id = aws_security_group.website_sg.id # Associando o security group à instância
  cidr_ipv4         = "0.0.0.0/0"                      # IP público
  from_port         = 80                               # Porta HTTP
  ip_protocol       = "tcp"
  to_port           = 80 # Porta HTTP

  tags = {
    Name        = "ec2-security-group"
    Provisioned = "Terraform"
    Cliente     = "David"
  }
}

# Regra de entrada para HTTPS
resource "aws_vpc_security_group_ingress_rule" "https_rule" {
  security_group_id = aws_security_group.website_sg.id # Associando o security group à instância
  cidr_ipv4         = "0.0.0.0/0"                      # IP público
  from_port         = 443                              # Porta HTTPS
  ip_protocol       = "tcp"
  to_port           = 443 # Porta HTTPS

  tags = {
    Name        = "ec2-security-group"
    Provisioned = "Terraform"
    Cliente     = "David"
  }
}

# Regra de saída para todas as portas
resource "aws_vpc_security_group_egress_rule" "all_ports_rule" { # Criando a regra de saída para todas as portas
  security_group_id = aws_security_group.website_sg.id           # Associando o security group à instância

  cidr_ipv4   = "0.0.0.0/0" # IP público
  ip_protocol = -1          # Protocolo -1 para todas as portas

  tags = {
    Name        = "ec2-security-group"
    Provisioned = "Terraform"
    Cliente     = "David"
  }
}