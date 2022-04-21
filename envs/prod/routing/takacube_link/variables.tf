/*
 * 変数enable_albを定義
 * ALBを作成すると1ヶ月2500円くらいかかる
 * enable_albをfalseにするとALBを作成しない。既に作成済みの場合はALBを削除する
*/
variable "enable_alb" {
  type    = bool
  default = true
}