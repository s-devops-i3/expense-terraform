module "frontend" {
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "frontend"
  ssh_user      = var.ssh_user
  ssh_pass      = var.ssh_pass
  env           = var.env
  zone_id       = var.zone_id
}

module "backend" {
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "backend"
  ssh_user      = var.ssh_user
  ssh_pass      = var.ssh_pass
  env           = var.env
  zone_id       = var.zone_id
}

module "mysql" {
  source        = "./module/app"
  instance_type = var.instance_type
  component     = "mysql"
  ssh_user      = var.ssh_user
  ssh_pass      = var.ssh_pass
  env           = var.env
  zone_id       = var.zone_id
}