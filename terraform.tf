terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.29"
    }
  }
}

# postgresql12.17を作成
module "postgresql" {
  source = "terraform-aws-modules/rds/aws"
  identifier = "my-postgresql-db"
  engine = "postgres"
  engine_version = "16.3"
  instance_class = "db.t3.micro"
#   name = "postgresql"
  username = "test"
  password = "test"
  port = 5432
  allocated_storage = 20
  max_allocated_storage = 100
  apply_immediately = true
  storage_type = "gp2"
  storage_encrypted = true
  multi_az = false
  publicly_accessible = false
  vpc_security_group_ids = [aws_security_group.default.id]
  db_subnet_group_name = aws_db_subnet_group.default.name
  parameter_group_name = aws_db_parameter_group.default16.name
  maintenance_window = "Mon:00:00-Mon:03:00"
  backup_window = "03:00-06:00"
  family = "postgres16"
  parameters = [
  # required for blue-green deployment
  {
    name         = "rds.logical_replication"
    value        = 1
    apply_method = "pending-reboot"
  }
]
  blue_green_update = {
    enabled = true
  }
    tags = {
    Name = "postgresql"
  }
}

# security group
resource "aws_security_group" "default" {
  name        = "test"
  description = "Allow all traffic"
  vpc_id      = aws_vpc.default.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    }
}

# VPC
resource "aws_vpc" "default" {
  cidr_block = "192.168.0.0/16"
}

# subnet
resource "aws_subnet" "default" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "192.168.1.0/24"
    availability_zone = "ap-northeast-1a"
}

resource "aws_subnet" "default_2" {
  vpc_id     = aws_vpc.default.id
  cidr_block = "192.168.2.0/24"
    availability_zone = "ap-northeast-1c"

}

# db subnet group
resource "aws_db_subnet_group" "default" {
  name       = "test"
  subnet_ids = [aws_subnet.default.id,
                aws_subnet.default_2.id]
}



# db parameter group
resource "aws_db_parameter_group" "default" {
  name         = "default"
  family       = "postgres12"
  description  = "default"
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

}

resource "aws_db_parameter_group" "default16" {
  name         = "default16"
  family       = "postgres16"
  description  = "default"
  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
    apply_method = "pending-reboot"
  }

}


data "aws_caller_identity" "current" {}

output "aws_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "aws_user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_arn" {
  value = data.aws_caller_identity.current.arn
}
