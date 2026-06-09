#!/bin/bash
set -euxo pipefail

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "========== Starting Jenkins Bootstrap =========="

# Update system
dnf update -y

# Install required packages
dnf install -y \
  wget \
  git \
  unzip \
  docker \
  java-21-amazon-corretto

# Set Java 21 as default
alternatives --set java \
/usr/lib/jvm/java-21-amazon-corretto.x86_64/bin/java

# Start Docker
systemctl enable docker
systemctl start docker

# Jenkins Repository
wget -O /etc/yum.repos.d/jenkins.repo \
https://pkg.jenkins.io/redhat-stable/jenkins.repo

rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

dnf clean all
dnf makecache

# Install Jenkins
dnf install -y jenkins

# Disable setup wizard
mkdir -p /var/lib/jenkins/init.groovy.d

cat > /var/lib/jenkins/init.groovy.d/create-admin.groovy <<'EOF'
#!groovy

import jenkins.model.*
import hudson.security.*

def instance = Jenkins.get()

def hudsonRealm = new HudsonPrivateSecurityRealm(false)

hudsonRealm.createAccount(
    "admin",
    "admin123"
)

instance.setSecurityRealm(hudsonRealm)

def strategy = new FullControlOnceLoggedInAuthorizationStrategy()

strategy.setAllowAnonymousRead(false)

instance.setAuthorizationStrategy(strategy)

instance.save()
EOF

# Start Jenkins
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

# Allow Jenkins to use Docker
usermod -aG docker jenkins

# Enable SSM Agent
systemctl enable amazon-ssm-agent
systemctl restart amazon-ssm-agent

# Install AWS CLI v2
cd /tmp

curl -o awscliv2.zip \
https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip

unzip -o awscliv2.zip

./aws/install

# Install Terraform
cat > /etc/yum.repos.d/hashicorp.repo <<'EOF'
[hashicorp]
name=HashiCorp Stable - $basearch
baseurl=https://rpm.releases.hashicorp.com/AmazonLinux/latest/$basearch/stable
enabled=1
gpgcheck=0
EOF

dnf install -y terraform

# Install kubectl
KUBECTL_VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)

curl -LO \
https://dl.k8s.io/release/$${KUBECTL_VERSION}/bin/linux/amd64/kubectl

install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Install Helm
curl -fsSL \
https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Verification
java --version
docker --version
terraform version
kubectl version --client
helm version

echo "========== Jenkins Bootstrap Completed =========="