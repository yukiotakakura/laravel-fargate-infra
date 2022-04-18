/*
 * サブネットの作成
 *
 * VPCに割り当てたIPアドレスの範囲をさらに区切ったものをサブネットと呼びます。
 * サブネットは、作成してすぐの状態ではインターネットにアクセスすることができません。
 * インターネットゲートウェイを利用し、また設定を行って始めてインターネットにアクセスすることができます。
 * こうしてインターネットへのアクセスを行うことが出来るサブネットのことを「パブリックサブネット」という。
 * 設定を行わずインターネットにアクセスすることができないサブネットのこを「プライベートサブネット」という。
*/
resource "aws_subnet" "public" {
  for_each = var.azs

  availability_zone       = "${data.aws_region.current.name}${each.key}"
  cidr_block              = each.value.public_cidr
  map_public_ip_on_launch = true
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-public-${each.key}"
  }
}

resource "aws_subnet" "private" {
  for_each = var.azs

  availability_zone       = "${data.aws_region.current.name}${each.key}"
  cidr_block              = each.value.private_cidr
  map_public_ip_on_launch = false
  vpc_id                  = aws_vpc.this.id

  tags = {
    Name = "${aws_vpc.this.tags.Name}-private-${each.key}"
  }
}