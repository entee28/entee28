#!/bin/sh

echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "* soft nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "* soft nproc 8192" | sudo tee -a /etc/security/limits.conf
echo "* hard nproc 8192" | sudo tee -a /etc/security/limits.conf

# Installing Docker
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Running Sonarqube
sudo docker volume create --name sonarqube_data
sudo docker volume create --name sonarqube_logs
sudo docker volume create --name sonarqube_extensions

sudo docker run -d --name sonarqube \
  -p 80:9000 \
  -e SONAR_JDBC_URL=$1 \
  -e SONAR_JDBC_USERNAME=sonarqube \
  -e SONAR_JDBC_PASSWORD=$2 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:community
