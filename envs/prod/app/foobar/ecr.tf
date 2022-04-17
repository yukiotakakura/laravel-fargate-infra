module "nginx" {
  source = "../../../../modules/ecr"

  # ECRのリポジトリ名となります。AWSのマネジメントコンソール上などにも表示される名前となります。
  name = "${local.name_prefix}-${local.service_name}-nginx"
}

module "php" {
  source = "../../../../modules/ecr"

  # ECRのリポジトリ名となります。AWSのマネジメントコンソール上などにも表示される名前となります。
  name = "${local.name_prefix}-${local.service_name}-php"
}