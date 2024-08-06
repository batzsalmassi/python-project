output "vpc_id" {
  value = aws_vpc.mainVPC.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "public_route_table_id" {
  value = aws_route_table.public-rt.id
}

output "private_route_table_id" {
  value = aws_route_table.private-rt.id
}

output "internet_gateway_id" {
  value = aws_internet_gateway.main-igw.id
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
  
}
