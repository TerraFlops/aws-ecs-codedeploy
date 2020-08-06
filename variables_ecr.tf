variable "ecr_repository_name" {
  description = "The name of the ECR repository where the artifact is located"
  type = string
}

variable "ecr_repository_image_tag" {
  description = "The image tag to be deployed. Defaults to LATEST"
  type = string
  default = "LATEST"
}

