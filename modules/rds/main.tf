resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project_name}-rds-subnet-group-${var.environment}"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "${var.project_name}-rds-subnet-group-${var.environment}"
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow database access from allowed security groups"
    from_port       = var.db_engine == "postgres" ? 5432 : 3306
    to_port         = var.db_engine == "postgres" ? 5432 : 3306
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-rds-sg-${var.environment}"
  }
}

resource "aws_db_instance" "main" {
  identifier        = "${var.project_name}-db-${var.environment}"
  engine            = var.db_engine
  engine_version    = var.db_engine_version
  instance_class    = var.db_instance_class
  allocated_storage = var.db_allocated_storage
  storage_type      = "gp3"

  db_name  = var.db_name
  username = var.db_username
  password = var.db_password
  port     = var.db_engine == "postgres" ? 5432 : 3306

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  multi_az            = var.environment == "prod" ? true : false
  publicly_accessible = false
  skip_final_snapshot = var.environment == "dev" ? true : false
  apply_immediately   = true

  # Note: in a production environment, you should encrypt storage and set up backups
  storage_encrypted = true

  tags = {
    Name = "${var.project_name}-rds-${var.environment}"
  }
}
