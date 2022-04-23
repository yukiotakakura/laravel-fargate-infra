/*
 * CloudWatchロググループ
 * nginxコンテナ用のロググループ
*/
resource "aws_cloudwatch_log_group" "nginx" {
  name = "/ecs/${local.name_prefix}-${local.service_name}/nginx"

  # ログ保存期間を90日
  retention_in_days = 90
}

/*
 * CloudWatchロググループ
 * phpコンテナ用のロググループ
*/
resource "aws_cloudwatch_log_group" "php" {
  name = "/ecs/${local.name_prefix}-${local.service_name}/php"

  # ログ保存期間を90日
  retention_in_days = 90
}