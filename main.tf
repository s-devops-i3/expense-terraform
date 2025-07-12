# module "frontend" {
#   depends_on = [module.backend]
#   source        = "./module/app"
#   instance_type = var.instance_type
#   component     = "frontend"
#   env           = var.env
#   zone_id       = var.zone_id
#   vault_token   = var.vault_token
# }
#
# module "backend" {
#   depends_on = [module.mysql]
#   source        = "./module/app"
#   instance_type = var.instance_type
#   component     = "backend"
#   env           = var.env
#   zone_id       = var.zone_id
#   vault_token   = var.vault_token
# }
#
module "mysql" {
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "mysql"
  zone_id       = var.zone_id
  env           = var.env
  vault_token   = var.vault_token
  vpc_id        = module.vpc.vpc_id
  db_subnet     = module.vpc.db_subnet
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

}




