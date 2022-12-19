#!/bin/bash
sudo apt-get update
sudo apt-get install -y docker.io ca-certificates curl \
  apt-transport-https lsb-release gnupg
sudo systemctl enable --now docker
sudo usermod -aG docker azureuser
sudo curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
sudo snap install kubectl --classic
sudo curl -sL https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | sudo bash

