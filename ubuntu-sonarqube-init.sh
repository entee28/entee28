#!/bin/sh

echo "vm.max_map_count=524288" | sudo tee -a /etc/sysctl.conf
echo "fs.file-max=131072" | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

echo "* soft nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 131072" | sudo tee -a /etc/security/limits.conf
echo "* soft nproc 8192" | sudo tee -a /etc/security/limits.conf
echo "* hard nproc 8192" | sudo tee -a /etc/security/limits.conf

# Installing Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Running Sonarqube
docker volume create --name sonarqube_data
docker volume create --name sonarqube_logs
docker volume create --name sonarqube_extensions

docker run -d --name sonarqube \
  -p 9000:9000 \
  -e SONAR_JDBC_URL=$1 \
  -e SONAR_JDBC_USERNAME=sonarqube \
  -e SONAR_JDBC_PASSWORD=$2 \
  -v sonarqube_data:/opt/sonarqube/data \
  -v sonarqube_extensions:/opt/sonarqube/extensions \
  -v sonarqube_logs:/opt/sonarqube/logs \
  sonarqube:community
