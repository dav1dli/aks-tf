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

## Azure KeyVault secret provider
[Use the Azure Key Vault Provider for Secrets Store CSI Driver in an AKS cluster](https://learn.microsoft.com/en-us/azure/aks/csi-secrets-store-driver)

Pre-requisite: SSL/TLS certificate is avaulable in KV-EUR-WW-POC-DL under name `my-certificate`.

Terraform automation enables KV SCI secret provider and outputs kv_secret_provider_client_id used as a value in userAssignedIdentityID. Value of tenantId is the Directory ID of the key vault. \
Example below shows a definition of AKS secretproviderclass providing access to a KV object with a TLS certificate in it:
```
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-tls
  namespace: ingress-nginx
spec:
  provider: azure
  parameters:
    tenantId: AAAA-BBBB-CCC
    usePodIdentity: "false"
    useVMManagedIdentity: "true"
    userAssignedIdentityID: QQQQQ-WWWW-EEEE
    keyvaultName: KV-EUR-WW-POC-DL
    objects: |
      array:
        - |
          objectName: my-certificate
          objectType: secret
  secretObjects:
  - data:
    - objectName: my-certificate
      key: tls.key
    - objectName: my-certificate
      key: tls.crt
    secretName: ingress-tls-csi
    type: kubernetes.io/tls
```
## Ingress controller: NGINX
Ingress controller allows to access services running in AKS from outside of the cluster.
```
User -> Public IP -> AKS LoadBalancer -> |k8s: Ingress Controller -> Ingress -> Service -> Pod 
```
AKS LoadBalancer is created by the ingress controller installation. It can create a piblic IP or use statically provided public IP. 

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
  --set controller.service.loadBalancerIP="12.34.56.78"
```
This is the most frequently described configuration putting ingress controller pods on Linux worker nodes.

Get public IP ID and set DNS name:
```
PUBLICIPID=$(az network public-ip list \
  --query "[?ipAddress!=null]|[?contains(ipAddress, '12.34.56.78')].[id]" --output tsv)
az network public-ip update --ids $PUBLICIPID --dns-name akspocdl-in
```
DNS FQDN:
```
az network public-ip list \
  --query "[?ipAddress!=null]|[?contains(ipAddress, '12.34.56.78')].dnsSettings.fqdn" \
  --output tsv
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
      service.beta.kubernetes.io/azure-load-balancer-health-probe-request-path: /healthz
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
   --set controller.service.loadBalancerIP="12.34.56.78"  -f values.yaml
```
Alternatively, set chart parameters from the command line:
```
helm install ingress-nginx ingress-nginx/ingress-nginx \
  --create-namespace --namespace ingress-nginx \
  --set controller.replicaCount=2 \
  --set controller.service.type=LoadBalancer \
  --set controller.service.externalTrafficPolicy=Local \
  --set controller.service.loadBalancerIP="12.34.56.78" \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-internal"=false \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-load-balancer-health-probe-request-path"=/healthz \
  --set controller.admissionWebhooks.patch.nodeSelector."kubernetes\.azure\.com/mode"=system \
  --set controller.admissionWebhooks.patch.tolerations[0].operator=Exists,defaultBackend.tolerations[0].key=CriticalAddonsOnly \
  --set controller.nodeSelector."kubernetes\.azure\.com/mode"=system \
  --set controller.tolerations[0].operator=Exists,controller.tolerations[0].key=CriticalAddonsOnly \
  --set defaultBackend.nodeSelector."kubernetes\.azure\.com/mode"=system \
  --set defaultBackend.tolerations[0].operator=Exists,defaultBackend.tolerations[0].key=CriticalAddonsOnly
```
## TLS certificate manager: cert-manager (optional)
In cases when AKS ingress uses Azure DNS for ingress public IP it is possible to use [cert-manager](https://cert-manager.io/) to manage valid certificates automatically. 

Upgrade the ingress controller - add DNS annotation:
```
helm upgrade ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.annotations."service\.beta\.kubernetes\.io/azure-dns-label-name"="myingress.westeurope.cloudapp.azure.com"
```
where `myingress.westeurope.cloudapp.azure.com` is the DNS name of the `loadBalancerIP`.

Install chart:
```
helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl label namespace ingress-nginx \
   cert-manager.io/disable-validation=true
helm install cert-manager jetstack/cert-manager \
  --namespace ingress-nginx \
  --set installCRDs=true \
  --set nodeSelector."kubernetes\.azure\.com/mode"=system \
  --set tolerations[0].operator=Exists,controller.tolerations[0].key=CriticalAddonsOnly
```
create a CA cluster issuer:
```
kubectl apply -f cluster-issuer.yaml
```
Configure an ingress which is going to use the created cluster issuer:
```
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt
...
spec:
  ingressClassName: nginx
  rules:
  - host: myingress.westeurope.cloudapp.azure.com
    http:
      paths:
      - backend:
...
  tls:
  - hosts:
    - myingress.westeurope.cloudapp.azure.com
    secretName: tls-secret
```