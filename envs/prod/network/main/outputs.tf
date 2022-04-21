/*
 * セキュリティグループID (web)
*/
output "security_group_web_id" {
  value = aws_security_group.web.id
}

/*
 * セキュリティグループID (vpc)
*/
output "security_group_vpc_id" {
  value = aws_security_group.vpc.id
}

/*
 * サブネットID
*/
output "subnet_public" {
  value = aws_subnet.public
}