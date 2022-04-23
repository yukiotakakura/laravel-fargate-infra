/*
 * ECSクラスターの作成
 * 
*/
resource "aws_ecs_cluster" "this" {
  name = "${local.name_prefix}-${local.service_name}"

  # ECSのタスクを実行するインフラを決める
  capacity_providers = [
    # 起動タイプをFargateとする
    "FARGATE",
    # これを指定することで7割引きの料金でFargateを使用することができる
    "FARGATE_SPOT"
  ]

  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}


/*
 * タスク定義の作成
 * 
*/
resource "aws_ecs_task_definition" "this" {

  # タスクの定義の名前を指定
  family = "${local.name_prefix}-${local.service_name}"

  # タスクロールのARNを指定 ※省略可能
  task_role_arn = aws_iam_role.ecs_task.arn

  # コンテナで使用するDockerネットワーキングモードを指定。Fargate起動タイプの場合は、「awsvpc」を指定
  network_mode = "awsvpc"

  # ECSの起動タイプを指定
  requires_compatibilities = [
    "FARGATE",
  ]

  # タスクに使用されるメモリとCPUのスペックを指定 ※組み合わせはドキュメントを参照
  execution_role_arn = aws_iam_role.ecs_task_execution.arn
  memory = "512"
  cpu    = "256"

  # タスクで動かす各コンテナの設定をJSON形式で記述。ここでは、nginxコンテナとphpコンテナの設定を記述
  container_definitions = jsonencode(
    [
      {
        name  = "nginx"

        # コンテナで使用するイメージのURLとタグを指定します。ここでは、各ECRのlatestイメージを使用する
        image = "${module.nginx.ecr_repository_this_repository_url}:latest"
        portMappings = [
          {
            containerPort = 80
            protocol      = "tcp"
          }
        ]
        # コンテナに渡す環境変数を指定
        environment = []

        # パラメータストアまたはSecrets Managerを指定すると、その値がコンテナに環境変数と渡されます。
        secrets     = []
        dependsOn = [
          {
            containerName = "php"
            condition     = "START"
          }
        ]

        # ボリュームのマウントポイントを指定します
        # docker-compose.yml見ると、nginxとPHP間の通信がUNIXドメインソケットであることがわかります。
        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]

        # コンテナのログ設定
        logConfiguration = {
          # これを指定することでCloudWatch Logsにコンテナのログが出力されます
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/nginx"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }
      },
      {
        name  = "php"
        image = "${module.php.ecr_repository_this_repository_url}:latest"
        portMappings = []
        environment = []

        # パラメータストアまたはSecrets Managerを指定すると、その値がコンテナに環境変数と渡されます。
        # phpコンテナでは、パラメータストアに登録済みの値を環境変数APP_KEYとして設定するようにしています。
        secrets = [
          {
            name      = "APP_KEY"
            valueFrom = "/${local.system_name}/${local.env_name}/${local.service_name}/APP_KEY"
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/run/php-fpm"
            sourceVolume  = "php-fpm-socket"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = "/ecs/${local.name_prefix}-${(local.service_name)}/php"
            awslogs-region        = data.aws_region.current.id
            awslogs-stream-prefix = "ecs"
          }
        }
      }
    ]
  )
  volume {
    name = "php-fpm-socket"
  }
  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}

/*
 * ECSサービスの定義
 * 
*/
resource "aws_ecs_service" "this" {
  # ECSのサービス名を指定
  name = "${local.name_prefix}-${local.service_name}"

  # 属するECSクラスターのARNを指定
  cluster = aws_ecs_cluster.this.arn

  # キャパシティプロバイダー戦略を指定
  # 本書では、学習目的なのでコスト重視である「FARGATE_SPOT」を指定
  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 0
    weight            = 1
  }

  # バージョンを固定
  platform_version = "1.4.0"

  # ECSサービスで使用するタスク定義のARNを指定
  task_definition = aws_ecs_task_definition.this.arn

  # 起動させておくタスク数を指定
  desired_count                      = var.desired_count

  # ECSのデプロイ方式であるローリングアップデートにおいて、全体でタスクを起動している状態をパーセンテージで指定
  deployment_minimum_healthy_percent = 100

  # ローリングアップデート時に全体で最大何個までタスクを起動している状態にするかをパーセンテージで指定
  # つまり、最大で「disired_count」の2倍の数までタスク起動が可能
  deployment_maximum_percent         = 200

  # 使用するロードバランサーに関する設定をおこないます。
  load_balancer {
    # ロードバランサーがトラフィックをフォーワードするコンテナ名とポート番号を指定
    container_name   = "nginx"
    container_port   = 80
    # タスクを登録するターゲットグループのARNを指定します ※appfoobar_link ➔ takacube_link
    target_group_arn = data.terraform_remote_state.routing_appfoobar_link.outputs.lb_target_group_foobar_arn
  }

  # タスクのヘルスチェック、コンテナチェックで異常が出た場合の無視する猶予期間
  health_check_grace_period_seconds = 60

  # タスクのネットワーク設定
  network_configuration {
    # タスクにパブリックIPを割当てるかどうかを指定。本書では、タスクをプライベートサブネットで起動させるのでパブリックIPは不要
    assign_public_ip = false
    # タスクに紐付けるセキュリティグループを指定
    security_groups = [
      data.terraform_remote_state.network_main.outputs.security_group_vpc_id
    ]
    # タスクが属するサブネットIDを指定
    subnets = [
      for s in data.terraform_remote_state.network_main.outputs.subnet_private : s.id
    ]
  }

  # ECS Execを利用する場合はtrue
  enable_execute_command = true
  tags = {
    Name = "${local.name_prefix}-${local.service_name}"
  }
}