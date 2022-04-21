data "terraform_remote_state" "network_main" {
  backend = "s3"

  config = {
    bucket = "laravel-fargate-app-tfstate-yt"
    key = "example/prod/network/foobar_v1.1.7.tfstate"
    #key    = "${local.system_name}/${local.env_name}/network/main_v1.1.7.tfstate"
    region = "ap-northeast-1"
  }
}

data "terraform_remote_state" "log_alb" {
  backend = "s3"

  config = {
    bucket = "laravel-fargate-app-tfstate-yt"
    key = "example/prod/log/alb_v1.1.7.tfstate"
    #key    = "${local.system_name}/${local.env_name}/log/alb_v1.1.7.tfstate"
    region = "ap-northeast-1"
  }
}