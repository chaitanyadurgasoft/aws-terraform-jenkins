resource "aws_instance" "Demo_Web_Public_Instance" {
  count                  = var.env == "Dev" ? 1 : 3
  ami                    = var.ami
  key_name               = lookup(var.key, var.region)
  instance_type          = var.instance_type
  subnet_id              = element(aws_subnet.Demo-Public-Subnets.*.id, count.index)
  vpc_security_group_ids = ["${aws_security_group.Demp-security-Web.id}"]
  tags = {
    Name = "${var.vpc_name}-Web-Server-${count.index + 1}"
  }
  user_data = <<EOF
#!/bin/bash
apt update -y
apt install nginx -y
service nginx start
echo "*************************************************************" 
echo "<h1><center>Web-Server</center></h1>" >> /var/www/html/index.nginx-debian.html
echo "*************************************************************"
echo "<h1><center>${var.vpc_name}-WebServer-${count.index + 1}</center></h1>" >> /var/www/html/index.nginx-debian.html
echo "*************************************************************"
EOF
}
