resource "aws_volume_attachment" "Demo-Volume-Attach" {
  count       = var.env == "Dev" ? 1 : 3
  device_name = "/dev/sdh"
  volume_id   = element(aws_ebs_volume.Demo-EBS-1.*.id, count.index)
  instance_id = element(aws_instance.Demo_Web_Public_Instance.*.id, count.index)
  depends_on  = [aws_ebs_volume.Demo-EBS-1]
}