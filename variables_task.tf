variable "task_container_family" {
  description = "Container family for ECS task"
  type = string
}

variable "task_container_definitions" {
  description = "Container definitions for the ECS task"
  type = string
}

variable "task_provision_role_arn" {
  description = "ARN of the IAM role that will be used to provision the ECS task"
  type = string
}

variable "task_execution_role_arn" {
  description = "ARN of the IAM role the ECS task will use during execution"
  type = string
}

variable "task_network_mode" {
  description = "Network mode for ECS task. Defaults to 'awsvpc'"
  type = string
  default = "awsvpc"
}

variable "task_cpu" {
  description = "The number of CPU units used by the task"
  type = number
}

variable "task_memory" {
  description = "The amount of memory (MiB) used by the task"
  type = number
}

variable "task_requires_compatibilities" {
  description = "Set of compatibilities the ECS task requires"
  type = set(string)
}

variable "task_docker_volumes" {
  description = "Optional set of docker volumes to be mounted"
  type = list(any)
  // type = list(object({
  //   name = string
  //   docker_volume_configuration = optional(object({
  //     scope = optional(string)
  //     autoprovision = optional(bool)
  //     driver = optional(string)
  //     driver_opts = optional(map(string))
  //     labels = optional(map(string))
  //   }))
  // })
  default = []
}
