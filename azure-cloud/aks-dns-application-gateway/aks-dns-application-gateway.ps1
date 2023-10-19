#############################################################################
# Setup Variables
#############################################################################
# Azure Subscription ID
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"

# Remaining Variables
$servicePrincipalClientName = "aks-dns-ag-sp"
$location = "westeurope"
$resourceGroupName = "aks-dns-ag-rg"
$ipAddressName = "aks-dns-ag-ip-address"
$vnetName = "aks-dns-ag-vnet"
$vnetAddressPrefix = "10.20.0.0/16"
$subnetAgName = "aks-dns-ag-subnet-application-gateway"
$subnetAgAddressPrefix = "10.20.10.0/24"
$subnetAksName = "aks-dns-ag-subnet-c1"
$subnetAksAddressPrefix = "10.20.20.0/27"
$subnetAksBackendIpAddress = "10.20.20.10"
$applicationGatewayName = "aks-dns-ag-application-gateway"
$aksName = "aks-dns-ag-c1"
$agentVMSize = "Standard_B2s"
$agentCount = "1"
$kubernetesVersion = "1.19.6"
$maxPods = "90"

#############################################################################
# Deploy Azure Resources
#############################################################################
# Set Current Subscription
az account set --subscription $subscription

# Create Service Principal
$client = (az ad sp create-for-rbac `
--skip-assignment `
--name $servicePrincipalClientName `
-o json) | ConvertFrom-Json
$clientId = $client.appId
$clientSecret = $client.password

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $resourceGroupName

# Assign Service Principal Role
az role assignment create `
--assignee $clientId `
--role "Contributor" `
--resource-group $resourceGroupName

# Deploy ARM Template
az group deployment create `
--mode Incremental `
--subscription $subscription `
--resource-group $resourceGroupName `
--template-file arm/aks-dns-ag-create.json `
--parameters `
location=$location `
ipAddressName=$ipAddressName `
vnetName=$vnetName `
vnetAddressPrefix=$vnetAddressPrefix `
subnetAgName=$subnetAgName `
subnetAgAddressPrefix=$subnetAgAddressPrefix `
subnetAksName=$subnetAksName `
subnetAksAddressPrefix=$subnetAksAddressPrefix `
subnetAksBackendIpAddress=$subnetAksBackendIpAddress `
applicationGatewayName=$applicationGatewayName `
aksName=$aksName `
agentVMSize=$agentVMSize `
agentCount=$agentCount `
kubernetesVersion=$kubernetesVersion `
maxPods=$maxPods `
servicePrincipalClientId=$clientId `
servicePrincipalClientSecret=$clientSecret

#############################################################################
# Deploy Applications in AKS
#############################################################################
# Get Credentials for AKS
az aks get-credentials `
--resource-group $resourceGroupName `
--name $aksName

# Show Context Details
kubectl config get-contexts
kubectl config current-context

# Deploy Sample AKS Application
kubectl apply -f yaml/deploy.yaml

# Deploy Ingress Controller
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
helm install nginx-ingress `
ingress-nginx/ingress-nginx `
--namespace aks-dns-ag `
--set controller.service.loadBalancerIP=$subnetAksBackendIpAddress `
-f yaml/ingress-internal-values.yaml

# Check Deployments
kubectl get all -n aks-dns-ag

#############################################################################
# Configure DNS
#############################################################################
# Acquire Public IP Address
Write-Host "Your IP Address =>" `
(az network public-ip show `
-g $resourceGroupName `
-n $ipAddressName `
-o json --query ipAddress)

#############################################################################
# Clean-up
#############################################################################
# Clear AKS Access Details
kubectl config delete-context $aksName
kubectl config unset users.clusterUser_"$resourceGroupName"_"$aksName"
kubectl config unset contexts.$aksName
kubectl config unset clusters.$aksName

# Delete Azure Resources
az ad sp delete --id $clientId
az group delete `
--subscription $subscription `
--name $resourceGroupName `
--yes