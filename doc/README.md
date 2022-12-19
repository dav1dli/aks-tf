# AKS Automation documentation

# Prerequisites
* access to Azure subscription with sufficient permissions
* terraform
* azure-cli
* kubectl
* ssh key pair

# Getting Started

## Azure
Login to Azure:
```
az login
```
If needed select a subscription:   
```
az account set --subscription XXXX-YYYY-ZZZZ
```
## Local system
Generate SSH key pair:
```
ssh-keygen \
    -m PEM \
    -t rsa \
    -b 4096 \
    -C "devops@mail.net" \
    -f ~/.ssh/aks-tf-ssh-key
```
## Terraform

Initialize terraform:
```
terraform -chdir=terraform  init -var-file=../environments/test/env.tfvars
```
Plan:
```
terraform -chdir=terraform  plan \
  -var-file=../environments/test/env.tfvars \
  -var ssh_public_key=~/.ssh/aks-tf-ssh-key.pub \
  -out=test.tflan
```
If necessary import pre-existing resources: 
```
terraform -chdir=terraform import azurerm_resource_group.aks_rg \
   /subscriptions/XXXX-YYYY-ZZZZ/resourceGroups/RG-EUR-WW-POC-DL
```
Apply:
```
terraform -chdir=terraform apply \
  -input=false -auto-approve test.tflan
```
At the end of successful deployment cluster parameters are printed out.

# Configuration

Environment specific parameters are configured in `environments/[ENV]/env.tfvars` files. They are passed to terraform as `-var-file` parameter. Terraform scripts in `terraform/` are expected to be generic for all environments.

SSH public key is a parameter allowing access to provisioned cluster nodes with `azureuser` and the private key from the pair. The private key can used as a local file but for shared aceess it should be published to a key vault.

# Work with AKS cluster

When the service is created setup access to the cluster:
```
az account set --subscription XXXX-YYYY-ZZZZ
az aks get-credentials --resource-group RG-EUR-WW-POC-DL --name AKS-EUR-WW-POC-DL
```
At this point `kubectl` cli can be used to operate the cluster: `kubectl get nodes`.

# Use jumphost

If the cluster is private, i.e. API server is not accessible it can be accessible only from the VNET.
For this purpose a jumphost - a Linux VM with management tools is provisioned. The jumphost is customized using `terraform/files/mng-vm-init.sh` script. 

In addition Azure Bastion interface is created. It allows to access the jumphost in a web browser.

Use bastion to connect to management VM / jumphost:
select the jumphost in Azure portal, click Connect, select Bastion, specify username: the admin user, authentication type: SSH private key, File: SSH private key. Click Connect. A shell session will open in a web browser.
