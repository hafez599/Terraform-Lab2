resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "${var.env}-redis"
  engine               = "redis"
  node_type            = "cache.t3.micro"
  num_cache_nodes      = 1
  subnet_group_name    = var.subnet_group_name
  parameter_group_name = "default.redis7"
}
