# AKS Automation documentation

# Prerequisites
* access to Azure subscription with sufficient permissions
* terraform >=1.2.9 <1.3 [GitHub issue](https://github.com/hashicorp/terraform/issues/32146)
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
### Bootstrap
Initialize terraform:
```
terraform -chdir=tf-bootstrap  init -var-file=../environments/poc/env.tfvars
```
Import pre-existing resource group: 
```
terraform -chdir=tf-bootstrap import azurerm_resource_group.tfstate \
   /subscriptions/XXXX-YYYY-ZZZZ/resourceGroups/RG-EUR-WW-POC-DL
```
Plan:
```
terraform -chdir=tf-bootstrap plan \
  -var-file=../environments/poc/env.tfvars \
  -out=tf-bootstrap.tflan
```
Apply:
```
terraform -chdir=tf-bootstrap apply \
  -input=false -auto-approve tf-bootstrap.tflan
```
The automation outputs its key parameters needed to setup the cloud storage backend for terraform. 
### Cloud infrastructure
Terraform expects environment variable `ARM_ACCESS_KEY` to be set to storage account access key.
Initialize terraform:
```
export ARM_ACCESS_KEY=$(az storage account keys list \
  --resource-group RG-EUR-WW-POC-DL \
  --account-name sapocdltfstate \
  --query '[0].value' -o tsv)
terraform -chdir=terraform  init \
  -var-file=../environments/poc/env.tfvars \
  -backend-config=../environments/poc/backend.tfvars
terraform import azurerm_resource_group.rg \
  /subscriptions/XXXX-YYYY-ZZZZ/resourceGroups/RG-EUR-WW-POC-DL
```
Plan:
```
terraform -chdir=terraform  plan \
  -var-file=../environments/poc/env.tfvars \
  -var ssh_public_key=~/.ssh/aks-tf-ssh-key.pub \
  -out=test.tflan
```
Apply:
```
terraform -chdir=terraform apply \
  -input=false -auto-approve test.tflan
```
A the end of successful deployment cluster parameters are printed out.

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

# Use the jumphost

A private cluster (API server is not accessible) can be accessible only from the VNET.
For this purpose a jumphost - a Linux VM with management tools - is provisioned. The jumphost is customized using `terraform/files/mng-vm-init.sh` script. 

In addition Azure Bastion interface is created. It allows the jumphost access via the web browser.

Use bastion to connect to management VM / jumphost: \
select the jumphost in Azure portal, click Connect, select Bastion, specify username: the admin user, authentication type: SSH private key, File: SSH private key. Click Connect. A shell session will open in a web browser.

The jumphost VM is provisioned with a managed identity to which required permissions are granted. To login with the managed identity: `az login --identity`.

*Note: only minimal permissions are provided, so not all interactive functions are available. For troubleshooting regular AD credentials with `az login` can be used.*

For example, get a secret from a key vault containing a ssh private key:
```
az keyvault secret show -n LXPOCDL --vault-name KV-EUR-WW-POC-DL \
  --query "value" --output tsv | base64 -d
```