# Azure CLI commands used to create AKS infrastructure

Account setup:
* Login to Azure: `az login` 
* If needed select a subscription: `az account set --subscription XXXX-YYYY-ZZZZ`

Create VNET and subnets:
```
az network vnet create -g RG-EUR-WW-POC-DL \
  -n VNET-EUR-WW-POC-DL --location westeurope -address-prefix 10.0.0.0/16

az network vnet subnet create -g RG-EUR-WW-POC-DL \
  --vnet-name VNET-EUR-WW-POC-DL --name SBN-NODE-EUR-WW-POC-DL \
  --address-prefixes 10.0.0.0/23

az network vnet subnet create -g RG-EUR-WW-POC-DL \
  --vnet-name VNET-EUR-WW-POC-DL --name SBN-POD-EUR-WW-POC-DL \
  --address-prefixes 10.0.32.0/19
```

Subnet IDs are required by AKS creation command:
```
az network vnet subnet list \
  --resource-group RG-EUR-WW-POC-DL \
  --vnet-name VNET-EUR-WW-POC-DL --query "[0].id" --output tsv
```
Create AKS cluster specifying subnets:
```
az aks create \
    --resource-group RG-EUR-WW-POC-DL \
    --node-resource-group RG-AKS-EUR-WW-POC-DL \
    --name AKS-EUR-WW-POC-DL \
    --network-plugin azure \
    --enable-managed-identity \
    --vnet-subnet-id /subscriptions/XXXX-YYYY-ZZZZ/resourceGroups/RG-EUR-WW-POC-DL/providers/Microsoft.Network/virtualNetworks/VNET-EUR-WW-POC-DL/subnets/SBN-NODE-EUR-WW-POC-DL \
    --pod-subnet-id /subscriptions/XXXX-YYYY-ZZZZ/resourceGroups/RG-EUR-WW-POC-DL/providers/Microsoft.Network/virtualNetworks/VNET-EUR-WW-POC-DL/subnets/SBN-POD-EUR-WW-POC-DL \
    --docker-bridge-address 172.17.0.1/16 \
    --dns-service-ip 10.1.0.10 \
    --service-cidr 10.1.0.0/16 \
    --generate-ssh-keys
```

When the service is created setup the cluster access:
```
az account set --subscription XXXX-YYYY-ZZZZ
az aks get-credentials --resource-group RG-EUR-WW-POC-DL --name AKS-EUR-WW-POC-DL
```
At this point `kubectl` cli can be used to operate the cluster: `kubectl get nodes`
