This project provides automation tools for creation of AKS development and production environments in Azure.

Directories:
* doc/ - project documentation
* terraform/ - IaC scripts

The project deploys an AKS cluster with following parameters:
* public API server
* nodepools for system and users workloads
* system managed identity
* Azure CNI