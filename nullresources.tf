resource "null_resource" "server-attach" {
  count = var.env == "Dev" ? 1 : 3
  provisioner "file" {
    source      = "script.sh"
    destination = "/tmp/script.sh"
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")
      host        = element(aws_instance.Demo_Web_Public_Instance.*.public_ip, count.index)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod 777 /tmp/script.sh",
      "sudo bash /tmp/script.sh",

    ]
    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("key.pem")
      host        = element(aws_instance.Demo_Web_Public_Instance.*.public_ip, count.index)
    }
  }
  provisioner "local-exec" {
    command = "echo ${element(aws_instance.Demo_Web_Public_Instance.*.public_ip, count.index)} > public_ip.txt"

  }
}