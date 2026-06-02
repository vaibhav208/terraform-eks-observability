variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR Block"
}

variable "project_name" {
  type        = string
  description = "Project Name"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public subnet CIDRs"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private subnet CIDRs"
}

variable "availability_zones" {
  type        = list(string)
  description = "Availability Zones"
}