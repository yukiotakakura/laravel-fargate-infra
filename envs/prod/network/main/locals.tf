locals {
  # NATゲートウェイを作成する個数に応じて(変数single_nat_gateway)、azを作る個数を決める
  # 現在は「a」だけ作られるようにしている。
  nat_gateway_azs = var.single_nat_gateway ? { keys(var.azs)[0] = values(var.azs)[0] } : var.azs
}