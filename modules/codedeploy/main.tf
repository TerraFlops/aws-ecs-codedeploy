resource "aws_iam_role" "codedeploy" {
  name = "${var.ecr_repository_name}CodeDeploy"
  assume_role_policy = data.aws_iam_policy_document.codedeploy_assume_role.json
}

resource "aws_iam_role_policy_attachment" "codedeploy" {
  policy_arn = "arn:aws:iam::aws:policy/AWSCodeDeployRoleForECSLimited"
  role = aws_iam_role.codedeploy.name
}

data "aws_iam_policy_document" "codedeploy_assume_role" {
  version = "2012-10-17"
  statement {
    effect = "Allow"
    principals {
      identifiers = [
        "codedeploy.amazonaws.com"
      ]
      type = "Service"
    }
  }
}

resource "aws_codedeploy_app" "application" {
  compute_platform = "ECS"
  name = var.ecr_repository_name
}

resource "aws_codedeploy_deployment_group" "application" {
  depends_on = [
    aws_iam_role_policy_attachment.codedeploy
  ]
  app_name = aws_codedeploy_app.application.name
  deployment_config_name = "CodeDeployDefault.ECSAllAtOnce"
  deployment_group_name = var.ecr_repository_name
  service_role_arn = aws_iam_role.codedeploy.arn
  auto_rollback_configuration {
    enabled = true
    events = [
      "DEPLOYMENT_FAILURE"
    ]
  }
  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action = "TERMINATE"
      termination_wait_time_in_minutes = 1
    }
  }
  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type = "BLUE_GREEN"
  }
  ecs_service {
    cluster_name = var.ecs_cluster_name
    service_name = var.ecs_service_name
  }
  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [
          var.alb_listener_arn
        ]
      }
      target_group {
        name = var.alb_blue_target_group_name
      }
      target_group {
        name = var.alb_green_target_group_name
      }
    }
  }
}