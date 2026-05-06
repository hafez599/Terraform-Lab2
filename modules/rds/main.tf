resource "aws_db_instance" "mysql" {
  identifier           = "${var.env}-mysql-db"
  allocated_storage    = 20
  engine               = "mysql"
  engine_version       = "8.0"
  instance_class       = "db.t3.micro"
  db_name              = "maindb"
  username             = "admin"
  password             = "password123" # Use secrets manager for real projects
  db_subnet_group_name = var.subnet_group_name
  vpc_security_group_ids = [var.rds_sg_id]
  skip_final_snapshot  = true
}
