module "api_deployment" {
  source = "git::https://github.com/TerraFlops/aws-ecs-codedeploy.git"
  vpc_id = module.vpc.vpc_id

  alb_enabled = true
  alb_deregistration_delay = 0
  alb_enable_deletion_protection = false
  alb_health_check_port = 80
  alb_health_check_protocol = "HTTP"
  alb_health_check_response_codes = "200"
  alb_health_check_timeout = 10
  alb_health_check_url = "/"
  alb_listener_protocol = "HTTPS"
  alb_listener_port = 443
  alb_listener_certificate_arn = ""
  alb_log_bucket = "api-alb.logs.optus-qr-connect.eonx.com"
  alb_log_bucket_create = true
  alb_target_port = 80
  alb_target_protocol = "HTTP"
  alb_subnet_ids = [
    module.vpc.subnet_ids["public_subnet_2a"],
    module.vpc.subnet_ids["public_subnet_2b"]
  ]
  alb_security_group_ids = [
    module.vpc.security_group_ids["api"]
  ]

  ecr_repository_name = "Api"
  ecr_repository_image_tag = "LATEST"

  ecs_cluster_name = "OptusQrConnect"
  ecs_cluster_create = true

  ecs_service_name = "Api"
  ecs_service_desired_count = 1
  ecs_service_create = true
  ecs_service_launch_type = "FARGATE"
  ecs_service_security_group_ids = [
    module.vpc.security_group_ids["api"]
  ]
  ecs_service_subnet_ids = [
    module.vpc.subnet_ids["compute_subnet_2a"],
    module.vpc.subnet_ids["compute_subnet_2b"]
  ]

  task_container_definitions = ""
  task_container_family = "OptusQrConnect"
  task_cpu = 1024
  task_memory = 2048
  task_execution_role_arn = ""
  task_provision_role_arn = ""
  task_requires_compatibilities = [
    "FARGATE"
  ]
  task_network_mode = "awsvpc"
  task_docker_volumes = [
    {
      name = "storage"
    }
  ]
}

locals {
  project_id = "optus-qr-connect"
  project_name = "Optus QR Connect"
  environment = "dev"
}

module "vpc" {
  source = "git::https://github.com/TerraFlops/aws-vpc.git"

  name = local.project_id
  description = local.project_name

  enable_dns_hostnames = true
  enable_dns_support = true

  cidr_block = "10.10.0.0/21"

  subnet_cidr_blocks = {
    public = [
      "10.10.1.0/25",
      "10.10.1.128/25"
    ],
    data = [
      "10.10.2.0/25",
      "10.10.2.128/25"
    ],
    compute = [
      "10.10.3.0/24",
      "10.10.4.0/24"
    ]
  }

  availability_zones = [
    "ap-southeast-2a",
    "ap-southeast-2b"
  ]

  # Create internet gateway in public subnet
  internet_gateway_enabled = true
  internet_gateway_subnet_type = "public"

  # Enable NAT instance in production, NAT gateways in lower environments
  nat_gateway_enabled = local.environment == "prod"
  nat_gateway_security_group = "nat"
  nat_instance_enabled = local.environment != "prod"
  nat_instance_security_group = "nat"

  # Security groups
  security_groups = merge({
      api = "Api security group",
      cron = "Cron security group",
      worker = "Worker security group",
      nat = "NAT ${local.environment == "prod" ? "gateway" : "instance"} security group"
    }
  )
  append_vpc_description = false

  security_group_rules = {
    api = [
      { direction="inbound", entity_type="cidr_block", entity_id="anywhere", ports="all", protocol="all" },
      { direction="outbound", entity_type="cidr_block", entity_id="anywhere", ports="all", protocol="all" }
    ]
    cron = [
      { direction="inbound", entity_type="cidr_block", entity_id="anywhere", ports="all", protocol="all" },
      { direction="outbound", entity_type="cidr_block", entity_id="anywhere", ports="all", protocol="all" }
    ]
    worker = [
      { direction="inbound", entity_type="cidr_block", entity_id="anywhere", ports="all", protocol="all" },
      { direction="outbound", entity_type="cidr_block", entity_id="anywhere", ports="all", protocol="all" }
    ]
  }
}