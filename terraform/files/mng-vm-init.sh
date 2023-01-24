#!/bin/bash
echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
sudo apt-add-repository "deb [arch=$(dpkg --print-architecture)] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get install -y docker.io ca-certificates curl \
  apt-transport-https lsb-release gnupg wget unzip software-properties-common gnupg2 terraform
sudo systemctl enable --now docker
sudo usermod -aG docker azureuser
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo snap install kubectl --classic
sudo curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash