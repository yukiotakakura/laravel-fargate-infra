/*
パブリックサブネット用ルートテーブルの作成

各パブリックサブネットから、単一のインターネットゲートウェイにルーティングすることとし、
各パブリックサブネットでは共通のルートテーブルひとつひとつを使用することにします。
*/
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public"
  }
}

/*
ルートテーブルに登録する、ひとつひとつのルートを作成します。
インターネットゲートウェイへのルートを作成したい場合には、引数gateway_idにインターネットゲートウェイのidを指定します。
また、引数route_table_idには、このルートを登録するルートテーブルのidを指定します。
*/
resource "aws_route" "internet_gateway_public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
  route_table_id         = aws_route_table.public.id
}

/*
パブリックルートテーブルとパブリックサブネットの紐付けを行います。
*/
resource "aws_route_table_association" "public" {
  for_each = var.azs

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[each.key].id
}


/*
 * プライベートサブネット用ルートテーブルの作成(NATゲートウェイの個数関係なく、複数作成)
 * 
 * 各プライベートサブネットから、単一のインターネットゲートウェイにルーティングすることとし、
 * 各プライベートサブネットでは共通のルートテーブルひとつひとつを使用することにします。
*/
resource "aws_route_table" "private" {
  for_each = var.azs

  vpc_id = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}

/*
 * プライベートサブネット用の各ルートテーブルに登録する、NATゲートウェイのルートを複数作成します。
*/
resource "aws_route" "nat_gateway_private" {
  for_each = var.enable_nat_gateway ? var.azs : {}

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[var.single_nat_gateway ? keys(var.azs)[0] : each.key].id
  route_table_id         = aws_route_table.private[each.key].id
}

/*
 * プライベートルートテーブルとプライベートサブネットの紐付けを行います。
*/
resource "aws_route_table_association" "private" {
  for_each = var.azs

  route_table_id = aws_route_table.private[each.key].id
  subnet_id      = aws_subnet.private[each.key].id
}