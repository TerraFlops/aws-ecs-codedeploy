variable "ecs_cluster_name" {
  description = "Name of the ECS cluster into which the application wil be deployed"
  type = string
}

variable "ecs_cluster_create" {
  description = "Boolean flag, if true a new ECS cluster will be created. If false an existing ECS cluster will be used. Defaults to false"
  type = bool
  default = false
}

variable "ecs_service_create" {
  description = "Boolean flag, if true a new ECS service will be created. If false an existing ECS service will be used. Defaults to false"
  type = bool
  default = false
}

variable "ecs_service_name" {
  description = "Name of the ECS service into which the application wil be deployed"
  type = string
}

variable "ecs_service_desired_count" {
  description = "Number of desired tasks. Defaults to 1"
  type = number
  default = 1
}

variable "ecs_service_launch_type" {
  description = "Launch type for ECS service. Defaults to 'FARGATE'"
  type = string
  default = "FARGATE"
}

variable "ecs_service_subnet_ids" {
  description = "Set of subnet IDs into which the ECS service will be deployed"
  type = set(string)
  default = []
}

variable "ecs_service_security_group_ids" {
  description = "Set of security group IDs which the ECS service will be assigned"
  type = set(string)
  default = []
}
