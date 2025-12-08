#!/bin/bash
set -e

#--------------------- System Update ---------------------
sudo yum update -y

#--------------------- Git Install -----------------------
sudo yum install -y git

#--------------------- Java 17 Install -------------------
# Use only one, Amazon Corretto 17 recommended for Jenkins and SonarQube
sudo yum install -y java-17-amazon-corretto-devel

# Verify Java
java -version

#--------------------- Jenkins Install -------------------

#first install java to run jenkins or else it won't work

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo yum install -y jenkins

sudo systemctl enable jenkins
sudo systemctl start jenkins

echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

#--------------------- Terraform Install -----------------
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum install -y terraform

#--------------------- Maven Install ---------------------
sudo yum install -y maven

#--------------------- kubectl Install -------------------
curl -LO "https://amazon-eks.s3.us-west-2.amazonaws.com/1.19.6/2021-01-05/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/

#--------------------- eksctl Install -------------------
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /usr/local/bin/

#--------------------- Trivy Install ---------------------
sudo rpm -ivh https://github.com/aquasecurity/trivy/releases/download/v0.48.3/trivy_0.48.3_Linux-64bit.rpm

#--------------------- Docker Install --------------------
sudo yum install -y docker
sudo usermod -aG docker ec2-user
sudo usermod -aG docker jenkins
sudo systemctl enable docker
sudo systemctl start docker
newgrp docker
sudo chmod 666 /var/run/docker.sock

#--------------------- SonarQube Docker Install ----------
# Remove previous container if exists
docker rm -f sonar || true

# Pull official latest SonarQube LTS image and run
docker pull sonarqube:lts
docker run -d --name sonar -p 9000:9000 sonarqube:lts

#--------------------- JFrog Artifactory Install ----------
sudo wget https://releases.jfrog.io/artifactory/artifactory-rpms/artifactory-rpms.repo -O /etc/yum.repos.d/jfrog-artifactory-rpms.repo
sudo yum install -y jfrog-artifactory-oss
sudo systemctl enable artifactory.service
sudo systemctl start artifactory.service

#--------------------- Terraformer Install ---------------
PROVIDER=all
curl -LO "https://github.com/GoogleCloudPlatform/terraformer/releases/download/$(curl -s https://api.github.com/repos/GoogleCloudPlatform/terraformer/releases/latest | grep tag_name | cut -d '"' -f 4)/terraformer-${PROVIDER}-linux-amd64"
chmod +x terraformer-${PROVIDER}-linux-amd64
sudo mv terraformer-${PROVIDER}-linux-amd64 /usr/local/bin/terraformer
