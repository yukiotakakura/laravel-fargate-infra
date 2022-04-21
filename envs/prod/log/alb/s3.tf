/*
 * S3バケットの作成
 * 
*/
resource "aws_s3_bucket" "this" {
  bucket = "takacube-${local.name_prefix}-alb-log"

  # s3の暗号化の設定を行う
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = "takacube-${local.name_prefix}-alb-log"
  }

  lifecycle_rule {
    # lifecycle_ruleを有効にする
    enabled = true

    expiration {
      # s3のオブジェクト(ALBのアクセスログファイル)を90日間保持する
      days = "90"
    }
  }
}

/*
 * バケットポリシーを作成
 * ALBがこのS3バケットにログを書き込みできるようにする為の設定
 * https://qiita.com/irico/items/a3ab1f8ebf1ece9cc783
*/
resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          # 許可の一覧であるAllow(ホワイトリスト)にするのか、禁止一覧あるDeny(ブラックリスト)にするのかを選びます。
          "Effect" : "Allow",

          # どの相手相手に対して許可ないし拒否するかを指定します。
          "Principal" : {
            # 〇〇であるAWSアカウトを指定
            "AWS" : "arn:aws:iam::${data.aws_elb_service_account.current.id}:root"
          },

          # 許可or拒否するアクション (putObject:s3に画像をアップロードする時に使う?)
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}/*"
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:PutObject",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}/*",
          "Condition" : {
            "StringEquals" : {
              "s3:x-amz-acl" : "bucket-owner-full-control"
            }
          }
        },
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "delivery.logs.amazonaws.com"
          },
          "Action" : "s3:GetBucketAcl",
          "Resource" : "arn:aws:s3:::${aws_s3_bucket.this.id}"
        }
      ]
    }
  )
}