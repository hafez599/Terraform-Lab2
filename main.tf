module "network" {
  source       = "./modules/network"
  env          = terraform.workspace
  vpc_cidr     = var.vpc_cidr
  public_cidr  = var.public_cidr
  app_cidr     = var.app_cidr
  db_cidr_1    = var.db_cidr_1
  db_cidr_2    = var.db_cidr_2
  cache_cidr_1 = var.cache_cidr_1
  cache_cidr_2 = var.cache_cidr_2
  az1          = "${var.region}a"
  az2          = "${var.region}b"
}

module "compute" {
  source           = "./modules/compute"
  env              = terraform.workspace
  instance_type    = var.instance_type
  public_subnet_id = module.network.public_subnet_id
  app_subnet_id    = module.network.app_subnet_id
  bastion_sg_id    = module.network.bastion_sg_id
  app_sg_id        = module.network.app_sg_id
}

module "rds" {
  source            = "./modules/rds"
  env               = terraform.workspace
  subnet_group_name = module.network.rds_subnet_group_name
  rds_sg_id         = module.network.rds_sg_id
}

module "redis" {
  source            = "./modules/redis"
  env               = terraform.workspace
  subnet_group_name = module.network.redis_subnet_group_name
}
module "notifications" {
  source       = "./modules/notifications"
  env          = terraform.workspace
  target_email = "hafezadel599@gmail.com" 
  state_bucket = "terraformbackendhafez"  
}
