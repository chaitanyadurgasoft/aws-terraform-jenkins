resource "aws_ebs_volume" "Demo-EBS-1" {
  count             = var.env == "Dev" ? 1 : 3
  availability_zone = element(var.az, count.index)
  size              = 2
  tags = {
    Name = "${var.vpc_name}-EBS-${count.index + 1}"
  }
  depends_on = [aws_instance.Demo_Web_Public_Instance]
}
