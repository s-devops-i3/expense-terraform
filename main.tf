# module "frontend" {
#   depends_on = [module.backend]
#   source        = "./module/app"
#   instance_type = var.instance_type
#   component     = "frontend"
#   env           = var.env
#   zone_id       = var.zone_id
#   vault_token   = var.vault_token
#   vpc_id        = module.vpc.vpc_id
#   subnets     = module.vpc.frontend_subnet
#   lb_type       = "Public"
#   lb_needed     = true
#   lb_subnet     = module.vpc.public_subnets
#   app_port      = 80
#   bastion_nodes = var.bastion_nodes
#   prometheus_nodes = var.prometheus_nodes
#   server_app_port_sg_cidr = var.public_subnets
#   lb_app_port_sg_cidr     = ["0.0.0.0/0"]
#   lb_ports                = {http:80, https:443}
#   certificate_arn         = var.certificate_arn
# }
#
# module "backend" {
#   depends_on = [module.rds]
#   source        = "./module/app"
#   instance_type = var.instance_type
#   component     = "backend"
#   env           = var.env
#   zone_id       = var.zone_id
#   vault_token   = var.vault_token
#   vpc_id        = module.vpc.vpc_id
#   subnets     = module.vpc.backend_subnet
#   lb_type       = "private"
#   lb_needed     = true
#   lb_subnet     = module.vpc.backend_subnet
#   app_port      = 8080
#   bastion_nodes = var.bastion_nodes
#   prometheus_nodes = var.prometheus_nodes
#   server_app_port_sg_cidr = concat(var.frontend_subnets,var.backend_subnets)
#   lb_app_port_sg_cidr     = var.frontend_subnets
#   lb_ports                = {http: 8080}
#
# }
module "frontend"{
  source = "./module/app-asg"
  depends_on              = [module.backend]

  app_port                = 80
  bastion_nodes           = var.bastion_nodes
  component               = "frontend"
  env                     = var.env
  instance_type           = var.instance_type
  max_size                = var.max_size
  min_size                = var.min_size
  prometheus_nodes        = var.prometheus_nodes
  server_app_port_sg_cidr = var.public_subnets
  subnets                 = module.vpc.frontend_subnet
  vpc_id                  = module.vpc.vpc_id
  vault_token             = var.vault_token
  lb_app_port_sg_cidr     = ["0.0.0.0/0"]
  lb_ports                = { http: 80, https:443 }
  lb_subnets              = module.vpc.public_subnets
  lb_type                 = "public"
  zone_id                 = var.zone_id
  certificate_arn         = var.certificate_arn
}

module "backend"{
  source = "./module/app-asg"

  depends_on              = [module.rds]
  app_port                = 8080
  bastion_nodes           = var.bastion_nodes
  component               = "backend"
  env                     = var.env
  instance_type           = var.instance_type
  max_size                = var.max_size
  min_size                = var.min_size
  prometheus_nodes        = var.prometheus_nodes
  server_app_port_sg_cidr = concat(var.frontend_subnets,var.backend_subnets)
  subnets                 = module.vpc.backend_subnet
  vpc_id                  = module.vpc.vpc_id
  vault_token             = var.vault_token
  lb_app_port_sg_cidr     = var.frontend_subnets
  lb_ports                = {http: 8080 }
  lb_subnets              = module.vpc.backend_subnet
  lb_type                 = "private"
  zone_id                 = var.zone_id
  certificate_arn         = var.certificate_arn
}

module "rds"{
  source = "./module/rds"

  allocated_storage             = 20
  component                     = "rds"
  engine                        = "mysql"
  engine_version                = "8.0.41"
  env                           = var.env
  family                        = "mysql8.0"
  instance_class                = "db.t3.micro"
  server_app_port_sg_cidr       = var.backend_subnets
  skip_final_snapshot           = true
  storage_type                  = "gp3"
  subnet_ids                    = module.vpc.db_subnets
  vpc_id                        = module.vpc.vpc_id
}
#vpc
module "vpc" {
  source = "./module/vpc"
  vpc_cidr_block            = var.vpc_cidr_block
  env                       = var.env

  default_vpc_id            = var.default_vpc_id
  default_vpc_cidr          = var.default_vpc_cidr
  default_route_table_id    = var.default_route_table_id
  frontend_subnets          = var.frontend_subnets
  backend_subnets           = var.backend_subnets
  db_subnets                = var.db_subnets
  availability_zones        = var.availability_zones
  public_subnets            = var.public_subnets

}








