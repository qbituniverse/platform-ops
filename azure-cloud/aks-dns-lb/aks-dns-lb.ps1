#############################################################################
# Setup Variables
#############################################################################
# Azure Subscription ID
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"

# Remaining Variables
$aksName = "aks-dns-lb-c1"
$resourceGroupName = "aks-dns-lb"
$location = "westeurope"
$nodeVMSize = "Standard_B2s"
$nodeCount = "1"
$kubernetesVersion = "1.19.7"
$maxPods = "110"
$diskSize = "32"

#############################################################################
# Deploy Azure Resources
#############################################################################
# Set Subscription
az account set --subscription $subscription

# Create Resource Group
az group create `
--subscription $subscription `
--name $resourceGroupName `
--location $location

# Create AKS
az aks create `
--name $aksName `
--subscription $subscription `
--resource-group $resourceGroupName `
--location $location `
--node-vm-size $nodeVMSize `
--node-count $nodeCount `
--kubernetes-version $kubernetesVersion `
--max-pods $maxPods `
--node-osdisk-size $diskSize `
--generate-ssh-keys

#############################################################################
# Access AKS
#############################################################################
# Get Context
az aks get-credentials `
--resource-group $resourceGroupName `
--name $aksName

# Check Context
kubectl config get-contexts
kubectl config current-context

# Create Namespace
kubectl create namespace aks-dns-lb

#############################################################################
# Configure DNS
#############################################################################
# Deploy Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress ingress-nginx/ingress-nginx `
--namespace aks-dns-lb `
--set controller.replicaCount=2 `
--set controller.nodeSelector."beta\.kubernetes\.io/os"=linux `
--set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux `
--set controller.admissionWebhooks.patch.nodeSelector."beta\.kubernetes\.io/os"=linux

# Acquire Public IP Address
Write-Host "Your IP Address =>" `
(kubectl get svc nginx-ingress-ingress-nginx-controller `
-n aks-dns-lb -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

# Configure DNS
# A Record => aks-dns-lb => Your IP Address

#############################################################################
# Configure SSL
#############################################################################
# Deploy Certificate Manager
kubectl label namespace aks-dns-lb cert-manager.io/disable-validation=true
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager jetstack/cert-manager `
--namespace aks-dns-lb `
--set installCRDs=true `
--set nodeSelector."kubernetes\.io/os"=linux `
--set webhook.nodeSelector."kubernetes\.io/os"=linux `
--set cainjector.nodeSelector."kubernetes\.io/os"=linux

#############################################################################
# Deploy Applications in AKS
#############################################################################
# Deploy Sample AKS Application
kubectl apply -f yaml/deploy.yaml

# Check Deployments
kubectl get all -n aks-dns-lb
kubectl get ingress -n aks-dns-lb
kubectl get certificate -n aks-dns-lb

#############################################################################
# Clean-up
#############################################################################
# Delete Azure Infrastructure
az group delete `
--subscription $subscription `
--name $resourceGroupName `
--yes

# Clear AKS Access Details
kubectl config delete-context $aksName
kubectl config unset users.clusterUser_"$resourceGroupName"_"$aksName"
kubectl config unset contexts.$aksName
kubectl config unset clusters.$aksName