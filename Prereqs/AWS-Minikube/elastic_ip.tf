resource "aws_eip" "linux-eip" {
  vpc  = true
  tags = {
    Name = "linux-eip"
  }
}

resource "aws_eip" "consul-dashboard-eip" {
  vpc  = true
  tags = {
    Name = "consul-dashboard-eip"
  }
}

resource "aws_eip_association" "linux-eip-association" {
  instance_id   = aws_instance.linux-server.id
  allocation_id = aws_eip.linux-eip.id
}

output "eip_dashboard_public_ip" {
  value = "${aws_eip.consul-dashboard-eip.public_ip}"
}

output "eip_dashboard_allocation_id" {
  value = "${aws_eip.consul-dashboard-eip.allocation_id}"
}

output "ssh_command" {
  value = "ssh -i linux-key-pair.pem ec2-user@${aws_eip_association.linux-eip-association.public_ip}"
}
