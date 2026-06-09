output "jenkins_instance_profile_name" {
  value = aws_iam_instance_profile.jenkins.name
}

output "bastion_instance_profile_name" {
  value = aws_iam_instance_profile.bastion.name
}

output "jenkins_role_arn" {
  value = aws_iam_role.jenkins.arn
}

output "bastion_role_arn" {
  value = aws_iam_role.bastion.arn
}