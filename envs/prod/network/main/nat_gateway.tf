/*
 * NATゲートウェイの作成
 * 
 * VPC内に構成した「プライベートサブネット」からインターネットに接続するためのゲートウェイ。
 * インターネットからのアクセスは遮断したいが、DBからインターネットにはアクセスした場合で使う。
*/
resource "aws_nat_gateway" "this" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : {}

  # NATゲートウェイに紐付けるElastic IPのidを指定
  allocation_id = aws_eip.nat_gateway[each.key].id
  # NATゲートウェイを紐付けるサブネットのidを指定。NATゲートウェイはパブリックサブネットに紐付けるようにする
  subnet_id     = aws_subnet.public[each.key].id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-${each.key}"
  }
}