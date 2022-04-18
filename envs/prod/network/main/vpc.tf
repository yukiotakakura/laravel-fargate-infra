/*
 * VPCの作成
 *
 * VPCを利用すると、そのユーザだけの仮想的に分離されたネットワークをのこと。
 * VPC内に、サブネットやインターネットゲートウェイなどを設定することでインターネットの構築を行う。
*/
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${local.name_prefix}-main"
  }
}