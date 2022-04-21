/*
 * ALBを作成する際にS3バケットのIDが必要になってくるので、これを参照できるようにします。
 * terraform_remote_stateというデータソースを使うことで、下記の値を別のファイルから参照することができる
*/
output "s3_bucket_this_id" {
  value = aws_s3_bucket.this.id
}