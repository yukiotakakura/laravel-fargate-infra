/*
 * ECSクラスターの作成
 * 
*/
resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"

  # ECSのタスクを実行するインフラを決める
  capacity_providers = [
    # 起動タイプをFargateとする
    "FARGATE",
    # これを指定することで7割引きの料金でFargateを使用することができる
    "FARGATE_SPOT"
  ]

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}


