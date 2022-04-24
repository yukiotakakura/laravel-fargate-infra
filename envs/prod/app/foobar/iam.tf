/*
 * タスク実行ロールの作成
 * 
 * タスクを起動させるにあたり、タスク実行ロールと呼ばれるIAMロールが必要となります。
*/
resource "aws_iam_role" "ecs_task_execution" {
  name = "${local.name_prefix}-${local.service_name}-ecs-task-execution"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-ecs-task-execution"
  }
}

data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = data.aws_iam_policy.ecs_task_execution.arn
}


/*
 * タスク実行ロールのポリシー追加
 * 
 * phpコンテナで必要となるAWSパラメータストアで設定したLaravelの環境変数を参照する為にタスク実行ロールに権限を追加する
*/
resource "aws_iam_policy" "ssm" {
  name = "${local.name_prefix}-${local.service_name}-ssm"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",

          # パラメータストアの読み取り権限を付与
          "Action" : [
            "ssm:GetParameters",
            "ssm:GetParameter"
          ],

          # パラメータストアが保存されているリソースの位置を指定
          "Resource" : "arn:aws:ssm:${data.aws_region.current.id}:${data.aws_caller_identity.self.account_id}:parameter/${local.system_name}/${local.env_name}/*"
        }
      ]
    }
  )

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-ssm"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_ssm" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.ssm.arn
}


/*
 * タスク実行ロールの権限実行
*/
resource "aws_iam_policy" "s3_env_file" {
  name = "${local.name_prefix}-${local.service_name}-s3-env-file"
  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : "s3:GetObject"
          "Resource" : "${aws_s3_bucket.env_file.arn}/*"
        },
        {
          "Effect" : "Allow",
          "Action" : "s3:GetBucketLocation"
          "Resource" : aws_s3_bucket.env_file.arn
        },
      ]
    }
  )

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-s3-env-file"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_s3_env_file" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = aws_iam_policy.s3_env_file.arn
}


/*
 * タスクロールの作成とECS Exec
 * 
 * 起動後のタスク上のコンテナから、AWSの各種APIを使用したい場合は、タスクロールというものに必要な権限を付与。
 * 例えば、phpコンテナのLaravelからS3を利用したい場合などは、タスクロールにS3に関する権限を付けます。
 * 本書では、ECS Execという機能を利用できる権限を持つタスクロールを作成します。
*/
resource "aws_iam_role" "ecs_task" {
  name = "${local.name_prefix}-${local.service_name}-ecs-task"

  assume_role_policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Principal" : {
            "Service" : "ecs-tasks.amazonaws.com"
          },
          "Action" : "sts:AssumeRole"
        }
      ]
    }
  )

  tags = {
    Name = "${local.name_prefix}-${local.service_name}-ecs-task"
  }
}

/*
 * ECS Execは、コンテナの中に入ることができる機能で、これを使う為の条件として
 * タスクロールにssmmessages関連の権限を付ける必要があるため、そのポリシーをここで作成
 * 
*/
resource "aws_iam_role_policy" "ecs_task_ssm" {
  name = "ssm"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "ssmmessages:CreateControlChannel",
            "ssmmessages:CreateDataChannel",
            "ssmmessages:OpenControlChannel",
            "ssmmessages:OpenDataChannel"
          ],
          "Resource" : "*"
        }
      ]
    }
  )
}