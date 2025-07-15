variable "instance_type" {}
variable "component" {}
variable "env" {}
variable "zone_id" {}
variable "vault_token" {}
variable "vpc_id" {}
variable "db_subnet" {}
variable "lb_needed" {
  default = false
}
variable "lb_type" {
  default = null
}
variable "lb_subnet" {
  default = null
}


