# Get default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Security Group
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-sg"
  description = "Allows SSH and database access"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "PostgreSQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg"
  }
}

# EC2 Instance
resource "aws_instance" "app_server" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (us-east-1)
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  subnet_id              = data.aws_subnets.default.ids[0]

  tags = {
    Name = "${var.project_name}-ec2"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
  tags = {
    Name = "${var.project_name}-subnet-group"
  }
}

# RDS Instance
resource "aws_db_instance" "app_db" {
  identifier             = "${var.project_name}-db"
  allocated_storage      = 20
  engine                 = "PostgreSQL"
  engine_version         = "8.0"
  instance_class         = "db.t2.micro"
  username               = var.db_username
  password               = var.db_password
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  skip_final_snapshot    = true

  tags = {
    Name = "${var.project_name}-rds"
  }
}
