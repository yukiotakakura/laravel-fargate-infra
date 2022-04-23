/*
 * ALBを作成
*/
resource "aws_lb" "this" {
  # 変数enable_albがtrueの場合に、ALBを作成する個数を1に設定
  count = var.enable_alb ? 1 : 0

  name = "${local.name_prefix}-takacube-link"

  # インターネット向けのロードバランサーを指定
  # trueにすると内部ロードバランサーとなり、falseにするとインターネット向けロードバランサーとなる。
  internal           = false

  # ALBを作成する場合は「application」、NLBを作成する場合は「network」、Gateway Load Balancerを作成する場合は「gateway」
  load_balancer_type = "application"

  # アクセスログをS3バケットに保存する場合は下記のブロックを指定
  access_logs {
    # terraform_remote_stateを使用して、S3のバケット名を取得
    bucket  = data.terraform_remote_state.log_alb.outputs.s3_bucket_this_id
    # trueにするとアクセスログが保存されるようになる
    enabled = true
    # プレフィックス名を指定
    prefix  = "takacube-link"
  }

  # このALBに紐付けるセキュリティグループを設定
  security_groups = [
    data.terraform_remote_state.network_main.outputs.security_group_web_id,
    data.terraform_remote_state.network_main.outputs.security_group_vpc_id
  ]

  # このALBが所属するサブネットを設定
  subnets = [
    for s in data.terraform_remote_state.network_main.outputs.subnet_public : s.id
  ]

  tags = {
    Name = "${local.name_prefix}-takacube-link"
  }
}

/*
 * ALBのリスナーの作成
 *
 * HTTPSのリクエストを受けるリスナー
*/
resource "aws_lb_listener" "https" {
  count = var.enable_alb ? 1 : 0

  # prodtocolに「HTTPS」を指定した場合は、証明書のARNを指定
  certificate_arn   = aws_acm_certificate.root.arn

  # このリスナーに紐づくロードバランサーのARNを指定します
  load_balancer_arn = aws_lb.this[0].arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"

  # リクエストを受付したときのデフォルトのアクションを指定
  default_action {
    type = "forward"

    target_group_arn = aws_lb_target_group.foobar.arn
  }
}

/*
 * ALBのリスナーの作成
 *
 * HTTPのリクエストを受付たらHTTPSへリダイレクトするリスナー
 * HTTPは非推奨なのでHTTPSにリダイレクトする
*/
resource "aws_lb_listener" "redirect_http_to_https" {
  count = var.enable_alb ? 1 : 0

  load_balancer_arn = aws_lb.this[0].arn
  port              = 80
  protocol          = "HTTP"

  # リクエストを受付したときのデフォルトのアクションを指定
  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

/*
 * ターゲットグループの作成
 *
*/
resource "aws_lb_target_group" "foobar" {
  name = "${local.name_prefix}-foobar"

  # タスクを解除する前にALBが待機する時間を指定します。自動デプロイの時間を短くしたいので60秒とする
  deregistration_delay = 60
  port                 = 80
  protocol             = "HTTP"
  target_type          = "ip"
  vpc_id               = data.terraform_remote_state.network_main.outputs.vpc_this_id

  # ヘルスチェック:サーバーが生きているかどうかのチェックするための設定
  health_check {
    # サーバー正常であると見なされるまでに、必要なヘルスチェックの連続回数
    healthy_threshold   = 2

    # ヘルスチェックのインターバルを秒で指定
    interval            = 30

    # どんなステータスコードが返ってきたら、正常とみなすかを指定
    matcher             = 200

    # ヘルスチェックで指定するパスを指定 ※完全ログイン製のアプリの場合は、注意
    path                = "/"

    # ヘルスチェックで使用するポート番号を指定
    # 「traffic-port」を指定すると、ターゲットがALBからのトラフィックを受信するポートが、ヘルスチェックでも使用される
    port                = "traffic-port"
    protocol            = "HTTP"

    # ここで指定した秒数の間、ターゲットからのレスポンスがないと、ヘルスチェックが失敗と見なされます。
    timeout             = 5

    # サーバー異常であると見なされるまでに、必要なヘルスチェックの連続回数
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${local.name_prefix}-foobar"
  }
}