This project provides automation tools for creation of AKS environments with required cloud infrastructure in Azure.

Directories:
* doc/ - project documentation
* tf-bootstrap/ - initialization of TF state remote storage 
* terraform/ - IaC scripts
* ansible/ - day2 system configuration

The project deploys an AKS cluster with following parameters:
* private API server
* nodepools for system and users workloads
* system managed identity
* Azure CNI
* KV CSI addon

In addition dependent cloud resources are created:
* Virtual network with subnets
* Azure container registry for locally managed container images
* Azure key vault for safe keeping secrets, certificates and keys
* Linux management VM and bastion host.

By default the AKS cluster is created private, i.e. the API endpoint is inaccessible from outside of the VNET. Thus k8s configuration is out of the scope of Terraform automation. It is performed by ansible running on the Linux management VM created by terraform.

See README files in sub-directories and in doc for more details.