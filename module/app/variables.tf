variable "instance_type" {}
variable "component" {}
variable "env" {}
variable "zone_id" {}
variable "vault_token" {}
variable "vpc_id" {}
variable "subnets" {}
variable "lb_needed" {
  default = false
}
variable "lb_type" {
  default = null
}
variable "lb_subnet" {
  default = null
}
variable "app_port" {
  default = null
}
variable "bastion_nodes" {}

