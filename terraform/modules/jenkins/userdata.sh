#!/bin/bash
set -euxo pipefail

# Log output
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========== STARTING JENKINS BOOTSTRAP =========="

# Update OS
dnf update -y --allowerasing

# Base packages
dnf install -y \
    wget \
    git \
    unzip \
    docker \
    java-21-amazon-corretto

# Docker
systemctl enable docker
systemctl start docker

# Jenkins Repository
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf clean all
dnf makecache

# Jenkins
dnf install -y jenkins

systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

usermod -aG docker jenkins

# SSM
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

# AWS CLI
cd /tmp

wget https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

unzip -o awscli-exe-linux-x86_64.zip

./aws/install

# Terraform Repository
cat > /etc/yum.repos.d/hashicorp.repo <<EOF
[hashicorp]
name=HashiCorp Stable
baseurl=https://rpm.releases.hashicorp.com/AmazonLinux/\$releasever/\$basearch/stable
enabled=1
gpgcheck=1
gpgkey=https://rpm.releases.hashicorp.com/gpg
EOF

dnf clean all
dnf makecache

# Terraform
dnf install -y terraform

# kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -LO \
https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verification
java -version
docker --version
aws --version
terraform version
kubectl version --client
helm version

echo "========== JENKINS BOOTSTRAP COMPLETED =========="