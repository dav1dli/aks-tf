# Ansible automation

Terraform creates a private AKS cluster, i.e. its API server is accessible only from the private VNET where the cluster is created.

Jumphost is a VM created in the same VNET and set up with AKS management tools. Jumphost VM IP is returned by the TF automation as `jumphost_public_ip`.

Another TF output needed by this Ansible playbook is `ingress_public_ip` - the IP of AKS cluster's ingress.

Ansible is an automation tool suitable for remote hosts configuration. It supports wide variety of modules including Kubernetes. Ansible configurations are YAML manifests.

Ansible automation is idempotent, i.e. the result of performing it once is exactly the same as the result of performing it repeatedly.

## Pre-requsites

* ansible
* ssh access to the jumphost

Install ansible:
* Mac OS: `brew install ansible`
* Linux: `python3 -m pip install ansible`

## Setup and run

Ansible playbook runs using `inventory` in which target hosts are configured.
Jumphost IP: `terraform -chdir=../terraform output -raw jumphost_public_ip`

Ansible is configtred in `ansible.cfg`, where host connectivity parameters are set.

Test connectivity to hosts in inventory: `ansible all -m ping -i inventory`

Run ansible playbook: 
```
ansible-playbook jumphost.yaml -i inventory \
  -e ingress_public_ip=<IP>
``` 
where IP - the output value of `ingress_public_ip` printed out by TF: `terraform output ingress_public_ip`.

Environment specific parameters are in vars/<env>.yaml files.

 ```
 ansible-playbook jumphost.yaml -i inventory.poc \
   -e tenant_id=$(terraform -chdir=../terraform output tenant_id) \
   -e user_assigned_id=$(terraform -chdir=../terraform output aks_kv_secret_provider_client_id) \
   -e kv_name=$(terraform -chdir=../terraform output kv_name) \
   -e ingress_public_ip=$(terraform -chdir=../terraform output ingress_public_ip) \
   -e @vars/poc.yaml
 ```