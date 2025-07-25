module "frontend" {
  depends_on = [module.backend]
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "frontend"
  env           = var.env
  zone_id       = var.zone_id
  vault_token   = var.vault_token
  vpc_id        = module.vpc.vpc_id
  subnets     = module.vpc.frontend_subnet
  lb_type       = "Public"
  lb_needed     = true
  lb_subnet     = module.vpc.public_subnets
  app_port      = 80
  bastion_nodes = var.bastion_nodes
  prometheus_nodes = var.prometheus_nodes
  server_app_port_sg_cidr = module.vpc.public_subnets
  lb_app_port_sg_cidr     = ["0.0.0.0/0"]
}

module "backend" {
  depends_on = [module.mysql]
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "backend"
  env           = var.env
  zone_id       = var.zone_id
  vault_token   = var.vault_token
  vpc_id        = module.vpc.vpc_id
  subnets     = module.vpc.backend_subnet
  lb_type       = "private"
  lb_needed     = true
  lb_subnet     = module.vpc.backend_subnet
  app_port      = 8080
  bastion_nodes = var.bastion_nodes
  prometheus_nodes = var.prometheus_nodes
  server_app_port_sg_cidr = concat(module.vpc.frontend_subnet,module.vpc.backend_subnet)
  lb_app_port_sg_cidr     = module.vpc.frontend_subnet
}
#
module "mysql" {
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "mysql"
  zone_id       = var.zone_id
  env           = var.env
  vault_token   = var.vault_token
  vpc_id        = module.vpc.vpc_id
  subnets       = module.vpc.db_subnets
  bastion_nodes = var.bastion_nodes
  prometheus_nodes = var.prometheus_nodes
  app_port         = 3306
  server_app_port_sg_cidr = module.vpc.backend_subnet
}
#----------------------------------------
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








