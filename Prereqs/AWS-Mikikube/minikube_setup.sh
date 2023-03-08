#! /bin/bash
sudo yum update -y
sudo yum install -y yum-utils
sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install https://download.docker.com/linux/centos/7/x86_64/stable/Packages/containerd.io-1.2.6-3.3.el7.x86_64.rpm
sudo dnf install --best --assumeyes docker-ce
sudo usermod -aG docker $USER && newgrp docker
sudo systemctl start docker
sudo curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-latest.x86_64.rpm
sudo rpm -Uvh minikube-latest.x86_64.rpm
sudo yum update -y 
minikube start -p dc1
minikube start -p dc2
