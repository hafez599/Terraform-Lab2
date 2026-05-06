output "vpc_id" { value = aws_vpc.this.id }
output "public_subnet_id" { value = aws_subnet.public.id }
output "app_subnet_id" { value = aws_subnet.app.id }
output "bastion_sg_id" { value = aws_security_group.bastion_sg.id }
output "app_sg_id" { value = aws_security_group.app_sg.id }
output "rds_sg_id" { value = aws_security_group.rds_sg.id }
output "rds_subnet_group_name" { value = aws_db_subnet_group.rds.name }
output "redis_subnet_group_name" { value = aws_elasticache_subnet_group.redis.name }
