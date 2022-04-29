terraform {
  backend "s3" {
    bucket = "laravel-fargate-app-tfstate-yt"
    key    = "example/prod/cache/foobar_v1.1.17.tfstate"
    region = "ap-northeast-1"
  }
}