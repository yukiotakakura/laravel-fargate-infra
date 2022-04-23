data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

data "terraform_remote_state" "network_main" {
  backend = "s3"

  config = {
    bucket = "laravel-fargate-app-tfstate-yt"
    key = "example/prod/network/foobar_v1.1.7.tfstate"
    #key    = "${local.system_name}/${local.env_name}/network/main_v1.1.7.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "routing_appfoobar_link" {
  backend = "s3"

  config = {
    bucket = "laravel-fargate-app-tfstate-yt"
    key = "example/prod/routing/takacube_link_v1.1.7.tfstate"
    #key    = "${local.system_name}/${local.env_name}/routing/appfoobar_link_v1.1.7.tfstate"
    region = "ap-northeast-1"
  }
}