module "vpc" {
  source = "./modules/vpc"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "jenkins_instance_profile" {
  value = module.iam.jenkins_instance_profile_name
}

output "bastion_instance_profile" {
  value = module.iam.bastion_instance_profile_name
}

module "jenkins" {
  source = "./modules/jenkins"

  project_name = var.project_name

  vpc_id = module.vpc.vpc_id

  public_subnet_id = module.vpc.public_subnet_ids[0]

  instance_profile_name = module.iam.jenkins_instance_profile_name
}

output "jenkins_url" {
  value = module.jenkins.jenkins_url
}