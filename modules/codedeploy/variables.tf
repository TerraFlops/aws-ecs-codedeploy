variable "ecs_cluster_name" {
  description = "The name of the ECS cluster where the application is deployed"
  type = string
}

variable "ecs_service_name" {
  description = "The name of the ECS service where the application is deployed"
  type = string
}

variable "ecr_repository_name" {
  description = "The name of the ECR repository where the artifact is located"
  type = string
}

variable "alb_listener_arn" {
  description = "The ARN of the ALB listener used to route traffic to the application"
  type = string
}

variable "alb_blue_target_group_name" {
  description = "The name of the blue ALB target group"
  type = string
}

variable "alb_green_target_group_name" {
  description = "The name of the green ALB target group"
  type = string
}

variable "ecr_image_tag" {
  description = "The image tag to be deployed. Defaults to LATEST"
  type = string
  default = "LATEST"
}

