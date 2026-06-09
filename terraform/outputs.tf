output "public_ip" {

  value = aws_eip.vpn_eip.public_ip

}

output "admin_url" {

  value = "https://${aws_eip.vpn_eip.public_ip}:943/admin"

}

output "client_url" {

  value = "https://${aws_eip.vpn_eip.public_ip}:943/"

}

output "ssh_command" {

  value = "ssh -i vpn-gateway-key.pem openvpn@${aws_eip.vpn_eip.public_ip}"

}