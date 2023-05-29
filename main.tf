data "aws_ami" "latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-6.1-x86_64"]
  }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.server_size
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "optional"
  }
  vpc_security_group_ids      = [aws_security_group.web.id]
  user_data_replace_on_change = true
  user_data                   = <<EOF
#!/bin/bash
yum -y update
yum -y install httpd
myip=`curl http://169.254.169.254/latest/meta-data/public-ipv4`
echo "<html>" > /var/www/html/index.html
echo "<body bgcolor='#1A5276'>" >> /var/www/html/index.html
echo "<center>" >> /var/www/html/index.html
echo "<br><h1><font color='#D68910'>Build by Power of Terraform with CLOUD</font></h1><br><br>" >> /var/www/html/index.html
echo "<br><h2><font color='#E74C3C'>${var.server_name}-WebServer with IP: $myip</font></h2><br><br>" >> /var/www/html/index.html
echo "<br><h3><font color='#27AE60'>Modified Content from ALB Version 1.0</font></h3><br><br>" >> /var/www/html/index.html
echo "<br><h2><font color='#E74C3C'>Mari Bubu Koba</font></h2><br><br>" >> /var/www/html/index.html
echo "</center>" >> /var/www/html/index.html
echo "</body>" >> /var/www/html/index.html
echo "</html>" >> /var/www/html/index.html
sudo service httpd start
chkconfig httpd on
EOF
  tags = {
    Name  = "${var.server_name}-WebServer"
    Owner = "Koba Skhulukhia"
  }
}

resource "aws_security_group" "web" {
  name_prefix = "${var.server_name}-WebServer-SG"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name  = "${var.server_name}-WebServer SecurityGroup"
    Owner = "Koba Skhulukhia"
  }
}

resource "aws_eip" "web" {
  instance = aws_instance.web.id
  tags = {
    Name  = "${var.server_name}-WebServer-IP"
    Owner = "Koba Skhulukhia"
  }
}
