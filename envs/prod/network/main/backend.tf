terraform {
  backend "s3" {
    # tfstate保存用のs3バケット名を指定
    bucket = "laravel-fargate-app-tfstate-yt"
    # 保存先のtfstateファイル名を指定します。命名:システム名/envs以下のパス/terraformバージョン名
    key    = "example/prod/network/foobar_v1.1.7.tfstate"
    region = "ap-northeast-1"
  }
}