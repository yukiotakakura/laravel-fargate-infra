/*
 * DBオプショングループの作成
 * 
 * DBオプショングループで使いたい機能が無いので、名前とエンジンバージョンを指定を行う
*/
resource "aws_db_option_group" "this" {
  name = "${local.system_name}-${local.env_name}-${local.service_name}"

  engine_name          = "mysql"
  major_engine_version = "8.0"

  tags = {
    Name = "${local.system_name}-${local.env_name}-${local.service_name}"
  }
}