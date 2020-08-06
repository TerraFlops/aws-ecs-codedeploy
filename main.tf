# Retrieve ECR repository
data "aws_ecr_repository" "application" {
  name = var.ecr_repository_name
}

# Retrieve requested ECR image from the repository
data "aws_ecr_image" "application" {
  repository_name = var.ecr_repository_name
  image_tag = var.ecr_repository_image_tag
}

# Create ALB if it was requested
module "alb" {
  source = "modules/alb"
  count = var.alb_enabled == true ? 1 : 0
  depends_on = [
    aws_s3_bucket.alb_logs
  ]
  target_type = "ip"
  name = var.ecr_repository_name
  subnet_ids = var.alb_subnet_ids
  vpc_id = var.vpc_id
  log_bucket = var.alb_log_bucket
  listener_port = var.alb_listener_port
  listener_protocol = var.alb_listener_protocol
  listener_ssl_policy = var.alb_listener_ssl_policy
  listener_certificate_arn = var.alb_listener_certificate_arn
  target_port = var.alb_target_port
  deregistration_delay = var.alb_deregistration_delay
  target_protocol = var.alb_target_protocol
  health_check_url = var.alb_health_check_url
  health_check_port = var.alb_health_check_port
  health_check_response_codes = var.alb_health_check_response_codes
  health_check_timeout = var.alb_health_check_timeout
  security_group_ids = var.alb_security_group_ids
  enable_deletion_protection = var.alb_enable_deletion_protection
  health_check_protocol = var.alb_health_check_protocol
}

# Create ALB log bucket if it was requested
resource "aws_s3_bucket" "alb_logs" {
  count = var.alb_enabled == true && var.alb_log_bucket_create == true ? 1 : 0
  bucket = var.alb_log_bucket
  tags = {
    Name = "${var.ecr_repository_name}ApplicationLoadBalancerLogBucket"
    ApplicationLoadBalancerName = var.ecr_repository_name
  }
}

# If we are not creating a new cluster, search for an existing one
data "aws_ecs_cluster" "application" {
  count = var.ecs_cluster_create == false ? 1 : 0
  cluster_name = var.ecs_cluster_name
}

# If we are creating a new cluster, create it
resource "aws_ecs_cluster" "application" {
  count = var.ecs_cluster_create == true ? 1 : 0
  name = var.ecs_cluster_name
}

# If we are not creating a new service, search for an existing one
data "aws_ecs_service" "application" {
  count = var.ecs_service_create == false ? 1 : 0
  cluster_arn = var.ecs_cluster_create == true ? aws_ecs_cluster.application[0].arn : data.aws_ecs_cluster.application[0].arn
  service_name = var.ecs_service_name
}

module "codedeploy" {
  source = "modules/codedeploy"
  alb_blue_target_group_name = module.alb.blue_target_group_name
  alb_green_target_group_name = module.alb.green_target_group_name
  alb_listener_arn = module.alb.alb_listener_arn
  ecr_repository_name = var.ecr_repository_name
  ecs_cluster_name = var.ecs_cluster_create == true ? aws_ecs_cluster.application[0].name : data.aws_ecs_cluster.application[0].cluster_name
  ecs_service_name = var.ecs_service_create == true ? aws_ecs_service.application[0].name : data.aws_ecs_service.application[0].service_name
  ecr_image_tag = var.ecr_repository_image_tag
}

# If we are creating a new service, create it
resource "aws_ecs_service" "application" {
  count = var.ecs_service_create == true ? 1 : 0
  cluster = var.ecs_cluster_create == true ? aws_ecs_cluster.application[0].arn : data.aws_ecs_cluster.application[0].arn
  name = var.ecs_service_name
  task_definition = aws_ecs_task_definition.application.arn
  desired_count = var.ecs_service_desired_count
  launch_type = var.ecs_service_launch_type
  iam_role = var.task_provision_role_arn
  network_configuration {
    subnets = var.ecs_service_subnet_ids
    security_groups = var.ecs_service_security_group_ids
  }
  # Link service to ALB
  load_balancer {
    target_group_arn = module.alb.green_target_group_arn
    container_name = var.ecr_repository_name
    container_port = var.alb_target_port
  }
}

resource "aws_ecs_task_definition" "application" {
  family = var.task_container_family
  container_definitions = var.task_container_definitions
  task_role_arn = var.task_provision_role_arn
  execution_role_arn = var.task_execution_role_arn
  cpu = var.task_cpu
  memory = var.task_memory
  network_mode = var.task_network_mode
  requires_compatibilities = var.task_requires_compatibilities

  # Add optional docker volumes to the container
  dynamic "volume" {
    for_each = var.task_docker_volumes
    content {
      name = volume.value["name"]
      dynamic "docker_volume_configuration" {
        for_each = volume.value["docker_volume_configuration"] == null ? {} : volume.value["docker_volume_configuration"]
        content {
          autoprovision = lookup(docker_volume_configuration.value, "autoprovision", null)
          driver = lookup(docker_volume_configuration.value, "driver", null)
          driver_opts = lookup(docker_volume_configuration.value, "driver_opts", null)
          labels = lookup(docker_volume_configuration.value, "labels", null)
          scope = lookup(docker_volume_configuration.value, "scope", null)
        }
      }
    }
  }
}