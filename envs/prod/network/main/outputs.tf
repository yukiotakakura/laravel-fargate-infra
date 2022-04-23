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
 * サブネットID(公開)
*/
output "subnet_public" {
  value = aws_subnet.public
}

/*
 * サブネットID(非公開)
 * ECSでタスクを起動させるサブネットのIDを指定
*/
output "subnet_private" {
  value = aws_subnet.private
}

/*
 * VPCのID
 * ターゲットグループの作成にあたり、VPCのIDが必要
*/
output "vpc_this_id" {
  value = aws_vpc.this.id
}
