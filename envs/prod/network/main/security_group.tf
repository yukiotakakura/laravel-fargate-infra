/*
 * WEBのセキュリティグループ
 * 
 * VPC外部からのHTTPやHTTPS通信を許可するセキュリティグループ
*/
resource "aws_security_group" "web" {
  name   = "${aws_vpc.this.tags.Name}-web"
  vpc_id = aws_vpc.this.id

  # インバウンド通信の許可設定
  ingress {
    # 許可するポート番号の範囲
    from_port   = 80
    to_port     = 80
    # 許可するプロトコル
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    # 許可するプロトコル (-1とすることで全てのプロトコルを許可することができる)
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-web"
  }
}

/*
 * VPCのセキュリティグループ
 * 
 * VPC作成時にAWSによって同一機能のセキュリティグループが自動的に作成されるが、
 * リソース名を変えたいのでTerraformでセキュリティグループを明示的に作成を行う
*/
resource "aws_security_group" "vpc" {
  name   = "${aws_vpc.this.tags.Name}-vpc"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    # このセキュリティグループに所属するリソースのみ通信を許可する
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-vpc"
  }
}

/*
 * RDS用セキュリティグループの作成
 * 
*/
resource "aws_security_group" "db_foobar" {
  name   = "${aws_vpc.this.tags.Name}-db-foobar"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-db-foobar"
  }
}

/*
 * ElastiCache用セキュリティグループの作成
 * 
*/
resource "aws_security_group" "cache_foobar" {
  name   = "${aws_vpc.this.tags.Name}-cache-foobar"
  vpc_id = aws_vpc.this.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${aws_vpc.this.tags.Name}-cache-foobar"
  }
}