resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
  tags       = { Name = "${var.env}-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.this.id
  tags   = { Name = "${var.env}-igw" }
}

# --- Subnets AZ 1 ---
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_cidr
  map_public_ip_on_launch = true
  availability_zone       = var.az1
  tags                    = { Name = "${var.env}-public-sn" }
}

resource "aws_subnet" "app" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.app_cidr
  availability_zone = var.az1
  tags              = { Name = "${var.env}-app-sn" }
}

resource "aws_subnet" "db_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_cidr_1
  availability_zone = var.az1
  tags              = { Name = "${var.env}-db-sn-1" }
}

resource "aws_subnet" "cache_1" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.cache_cidr_1
  availability_zone = var.az1
  tags              = { Name = "${var.env}-cache-sn-1" }
}

# --- Subnets AZ 2 (Required for RDS/Redis) ---
resource "aws_subnet" "db_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.db_cidr_2
  availability_zone = var.az2
  tags              = { Name = "${var.env}-db-sn-2" }
}

resource "aws_subnet" "cache_2" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.cache_cidr_2
  availability_zone = var.az2
  tags              = { Name = "${var.env}-cache-sn-2" }
}

# --- Routing ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# --- Security Groups ---
resource "aws_security_group" "bastion_sg" {
  name   = "${var.env}-bastion-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "app_sg" {
  name   = "${var.env}-app-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name   = "${var.env}-rds-sg"
  vpc_id = aws_vpc.this.id
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }
}

# --- Subnet Groups (Multi-AZ) ---
resource "aws_db_subnet_group" "rds" {
  name       = "${var.env}-rds-sng"
  subnet_ids = [aws_subnet.db_1.id, aws_subnet.db_2.id]
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.env}-redis-sng"
  subnet_ids = [aws_subnet.cache_1.id, aws_subnet.cache_2.id]
}
