# Azure CLI commands used to configure AKS cluster
Once a basic AKS cluster is created additional features can be configured. Those include:
* add a node pool for users workloads
* install ingress controller

## Node pools
By default the node pool created with the cluster is a system node pool. It is preferred by the cluster scheduling cluster system specific workloads.

In order to have a set of workers dedicated to run users workloads create an additional node pool of type 'User':
```
az aks nodepool add \
    --resource-group RG-EUR-WW-POC-DL \
    --cluster-name AKS-EUR-WW-POC-DL \
    --name userpool \
    --node-count 3 \
    --mode User \
    --zones 1 2 3
```

## Enable Key Vault Secrets Provider
Mount secrets stored in Azure Key Vault in AKS pods:
```
az aks enable-addons --addons azure-keyvault-secrets-provider \
  --name AKS-EUR-WW-POC-DL --resource-group RG-EUR-WW-POC-DL
```

## Ingress controller: NGINX
Static public IP:
```
az network public-ip create --resource-group RG-AKS-EUR-WW-POC-DL \
  --name AKS-EUR-WW-POC-DL-publicIp --allocation-method static \
  --sku Standard --query publicIp.ipAddress -o tsv
```
Install helm chart:
```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace \
  --namespace ingress-nginx \
  --set controller.nodeSelector."kubernetes\.io/os"=linux \
  --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.service.loadBalancerIP="52.174.178.138"
```
Get public IP ID and set DNS name:
```
PUBLICIPID=$(az network public-ip list \
  --query "[?ipAddress!=null]|[?contains(ipAddress, '52.174.178.138')].[id]" --output tsv)
az network public-ip update --ids $PUBLICIPID --dns-name akspocdl-in
```
In order to install the ingress controller on system nodes a taint must be tolerated:
```
CriticalAddonsOnly=true:NoSchedule
```
Use values.yaml file to include parameters:
```
controller:
  service:
    type: LoadBalancer
    externalTrafficPolicy: Local
    annotations:
      service.beta.kubernetes.io/azure-load-balancer-internal: "false"
  nodeSelector:
    kubernetes.azure.com/mode: "system"
  tolerations:
    - key: "CriticalAddonsOnly"
      operator: "Exists"
defaultBackend:
  nodeSelector:
    kubernetes.azure.com/mode: system
  tolerations:
    - key: "CriticalAddonsOnly"
      operator: "Exists"
```
Install helm chart:
```
 helm install ingress-nginx ingress-nginx/ingress-nginx \
   --create-namespace   --namespace ingress-nginx  \
   --set controller.service.loadBalancerIP="52.174.178.138"  -f values.yaml
```