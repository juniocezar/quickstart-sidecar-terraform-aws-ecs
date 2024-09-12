# just use current aws region when region is required
data "aws_region" "current" {}

# Get account id for policy creation
data "aws_caller_identity" "current" {}

# Sidecar Client ID/Secret stores in SSM
resource "aws_ssm_parameter" "sidecar_client_id" {
  name  = "/cyral/${var.sidecar_id}/client_id"
  value = var.client_id
  type  = "String"
}

resource "aws_ssm_parameter" "sidecar_client_secret" {
  name  = "/cyral/${var.sidecar_id}/client_secret"
  value = var.client_secret
  type  = "SecureString"
}


# Role/Policy for ECS execution policy that gives the required access
resource "aws_iam_role" "ecs_role" {
  count = var.precreated_ecs_role_arn == null ? 1 : 0

  name = "cyral_sidecar_ecs_role"
  assume_role_policy = jsonencode({
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
  })

  inline_policy {
    name        = "cyral_sidecar_ecs_policy"

    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue",
            "ssm:GetParameters",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/cyral/*",
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/cyral/*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*"
          ]
        }
      ]
    })
  }
}

resource "aws_iam_role" "ecs_task_role" {
  count = var.precreated_ecs_task_role_arn == null ? 1 : 0


  name = "cyral_sidecar_ecs_task_role"
  assume_role_policy = jsonencode({
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
  })

  inline_policy {
    name = "cyral_sidecar_ecs_task_policy"
    policy = jsonencode({
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Effect" : "Allow",
          "Action" : [
            "secretsmanager:GetSecretValue",
            "logs:CreateLogGroup",
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ],
          "Resource" : [
            "arn:aws:secretsmanager:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:secret:/cyral/*",
            "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:*",
            "arn:aws:ecr:*"
          ]
        }
      ]
    })
  }
}
