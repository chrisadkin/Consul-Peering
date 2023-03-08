resource "aws_eip" "linux-eip" {
  vpc  = true
  tags = {
    Name = "linux-eip"
  }
}

resource "aws_eip_association" "linux-eip-association" {
  instance_id   = aws_instance.linux-server.id
  allocation_id = aws_eip.linux-eip.id
}

output "ssh_command" {
  value = "ssh -i linux-key-pair.pem ec2-user@${aws_eip_association.linux-eip-association.public_ip}"
}
