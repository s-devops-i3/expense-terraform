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
# module "mysql" {
#   source        = "./module/app"
#   instance_type = var.instance_type
#   component     = "mysql"
#   zone_id       = var.zone_id
#   env           = var.env
#   vault_token   = var.vault_token
# }
#----------------------------------------
#vpc
module "vpc" {
  source = "./module/vpc"
  vpc_cidr_block = var.vpc_cidr_block
  env            = var.env
  subnet_cidr_block = var.subnet_cidr_block
}




