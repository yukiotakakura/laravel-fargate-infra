terraform {
  backend "s3" {
    bucket = "laravel-fargate-app-tfstate-yt"
    key    = "example/prod/db/foobar_v1.1.7.tfstate"
    region = "ap-northeast-1"
  }
}