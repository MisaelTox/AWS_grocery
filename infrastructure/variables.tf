variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "aws_grocery"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "db_username" {
  description = "RDS user name"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}

