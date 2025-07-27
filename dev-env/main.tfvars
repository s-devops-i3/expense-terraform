env="dev"

instance_type= "t3.small"
zone_id= "Z067408937AZSMI5YD79X"

#vpc
vpc_cidr_block = "10.10.0.0/24"

default_vpc_id = "vpc-0d777bc0eeb02d730"
default_vpc_cidr = "172.31.0.0/16"
default_route_table_id = "rtb-0dfd6bd58ec8c4869"
frontend_subnets  = ["10.10.0.0/27", "10.10.0.32/27"]
backend_subnets   = ["10.10.0.64/27", "10.10.0.96/27"]
db_subnets        = ["10.10.0.128/27", "10.10.0.160/27"]
public_subnets    = ["10.10.0.192/27", "10.10.0.224/27"]
availability_zones = ["us-east-1a", "us-east-1b"]
bastion_nodes      = ["172.31.30.120/32"]
prometheus_nodes   = ["172.31.80.62/32"]
certificate_arn    = "arn:aws:acm:us-east-1:471112569439:certificate/cfa1295f-77c6-4f2a-9bf3-560a008b1d3a"

