variable "alb_enabled" {
  description = "If true an ALB will be provisioned and mapped to the deployed ECS task"
  type = bool
  default = false
}

variable "alb_enable_deletion_protection" {
  description = "If an ALB is enabled, this is a boolean flag if true deletion protection will be enabled. Defaults to false"
  type = bool
  default = false
}

variable "alb_log_bucket" {
  description = "If an ALB is enabled, this is the name of the log bucket to which ALB logs will be written. If none is supplied a bucket name will be generated based on the ECS task name"
  type = string
  default = null
}

variable "alb_log_bucket_create" {
  description = "If an ALB is enabled, this is a boolean flag if true a new S3 log bucket will be created. If false the bucket must already exist with appropriate permissions for the ALB to write to it"
  type = bool
  default = false
}

# Listener settings

variable "alb_listener_port" {
  description = "If an ALB is enabled, this is the port number on which the ALB will listen for traffic. Defaults to 443"
  type = number
  default = 443
}

variable "alb_listener_protocol" {
  description = "If an ALB is enabled, this is the protocol it will use when listening for traffic. Defaults to HTTPS"
  type = string
  default = "HTTPS"
}

variable "alb_listener_ssl_policy" {
  description = "If an ALB is enabled and the protocol is HTTPS, this is the SSL neogitation policy that will be used. Defaults to ELBSecurityPolicy-2016-08"
  type = string
  default = "ELBSecurityPolicy-2016-08"
}

variable "alb_listener_certificate_arn" {
  description = "If an ALB is enabled and the protocol is HTTPS, this is the ARN of the ACM certificate that will be presented to incoming traffic"
  type = string
  default = null
}

# Target container settings

variable "alb_target_port" {
  description = "If an ALB is enabled, this is the internal port number that is exposed on the ECS container to which traffic will be directed. Defaults to 443"
  type = number
  default = 443
}

variable "alb_deregistration_delay" {
  description = "If an ALB is enabled, this is the deregistration delay prior to deregistering servers. Defaults to 60 seconds"
  type = number
  default = 60
}

variable "alb_target_protocol" {
  description = "If an ALB is enabled, this is the protocol it will use when communicating with the ECS container. Defaults to HTTPS"
  type = string
  default = "HTTPS"
}

# Health check settings

variable "alb_health_check_url" {
  description = "If an ALB is enabled, this is the URL that will be used when performing health checks. Defaults to '/health'"
  type = string
  default = "/health"
}

variable "alb_health_check_port" {
  description = "If an ALB is enabled, this is the port that will be used when performing health checks. Defaults to the ALB container port if no value specified"
  type = number
  default = null
}

variable "alb_health_check_protocol" {
  description = "If an ALB is enabled, the protocol that will be used when performing health checks. Defaults to HTTPS"
  type = string
  default = "HTTPS"
}

variable "alb_health_check_response_codes" {
  description = "If an ALB is enabled, this is a comma-separated list of HTTP status codes which will be treated as a successful health check. Defaults to 200"
  type = string
  default = "200"
}

variable "alb_health_check_timeout" {
  description = "If an ALB is enabled, this is the number of seconds the health check will wait for a response. Defaults to 5"
  type = number
  default = 5
}

# VPC settings

variable "alb_security_group_ids" {
  description = "If an ALB is enabled, this is an optional set of security group IPs to be applied to the ALB"
  type = set(string)
  default = []
}

variable "alb_subnet_ids" {
  description = "If an ALB is enabled, this is a set of subnet IDs in which the ALB will be provisioned"
  type = set(string)
}
