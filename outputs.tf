output "a_VPC_ID" {
  value = aws_vpc.main-vpc.id
}

output "b_Public_Subnet_ID" {
  value = aws_subnet.public.id
}

output "c_Private_Subnet_ID" {
  value = aws_subnet.private.id
}

output "d_Internet_Gateway_ID" {
  value = aws_internet_gateway.igw.id
}

output "e_Route_Table_ID" {
  value = aws_route_table.public.id
}

output "f_Route_Table_Association_ID" {
  value = aws_route_table_association.public_assoc.id
}

