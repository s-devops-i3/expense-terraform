output "vpc_id" {
  value = aws_vpc.main.id
}

output "frontend_subnet" {
  value = aws_subnet.frontend.*.id
}

output "backend_subnet" {
  value = aws_subnet.backend.*.id
}

output "db_subnet" {
  value = aws_subnet.db.*.id
}
output "public_subnets" {
  value = aws_subnet.public.*.id
}