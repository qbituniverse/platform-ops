## AKS Cluster

### Azure Kubernetes Service (AKS) with az cli

In this tutorial we'll deploy, modify and delete Kubernetes AKS cluster in Azure using [az cli](https://docs.microsoft.com/en-us/cli/azure/).

## Dependencies

The AKS cluster depends on several Azure resources or resource versions, as defined below. You might have some of these already created or defined on your Azure infrastructure. If not, please use the code snippets below to create these prior to provisioning your AKS cluster.

|Resource|Details|
|-----|-----|
|Service Principal|Service Principal is the key to proper functioning of the AKS cluster. It's bound to your AKS cluster itself and it'll be used to deploy applications onto your AKS cluster via DevOps.|
|AKS Resource Group|This is simply a container for your AKS cluster resources, and it needs to be created prior to provisioning your AKS cluster. The Service Principal needs to have *Contributor* Role assigned on your AKS cluster Resource Group.|
|Networking|You need to have Vnet in place and a dedicated Subnet for your AKS cluster created on that Vnet. The Service Principal needs to have *Contributor* Role assigned on the AKS Subnet and *Reader* Role assigned on the Vnet.|
|Kubernetes Version|Kubernetes is constantly evolving, therefore, you need to define what version of the orchestrator you wish to install or upgrade to in order to stay up to date.|
|Kubernetes Node Size|Node is simply a Virtual Machine running your AKS, you can have one or many nodes defined per your AKS cluster. It's also referred to as *Agent* in AKS.|

### Service Principal

```powershell
# Variables
$servicePrincipalClientName = "<SERVICE PRINCIPAL NAME>"

# Example
$servicePrincipalClientName = "sp-aks-c1"

# Create Service Principal
$client = (az ad sp create-for-rbac `
--skip-assignment `
--name $servicePrincipalClientName `
-o json) | ConvertFrom-Json
$servicePrincipalClientId = $client.appId
$servicePrincipalClientSecret = $client.password
```

### AKS Resource Group

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$aksRg = "<AKS RESOURCE GROUP NAME>"
$servicePrincipalClientId = "<AKS SERVICE PRINCIPAL ID>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$aksRg = "rg-aks-c1"
$servicePrincipalClientId = $client.appId

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $aksRg

# Assign Service Principal Role
az role assignment create `
--assignee $servicePrincipalClientId `
--role "Contributor" `
--resource-group $aksRg
```

### Networking

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"
$vnetName = "<VNET NAME>"
$vnetAddressPrefix = "<VNET ADDRESS SPACE>"
$subnetName = "<SUBNET NAME>"
$subnetAddressPrefix = "<SUBNET ADDRESS SPACE>"
$servicePrincipalClientId = "<AKS SERVICE PRINCIPAL ID>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$vnetRg = "rg-vnet"
$vnetName = "vnet-main"
$vnetAddressPrefix = "10.20.0.0/16"
$subnetName = "subnet-aks-c1"
$subnetAddressPrefix = "10.20.10.0/27"
$servicePrincipalClientId = $client.appId

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $vnetRg

# Create Network
az network vnet create `
--subscription $subscription `
-l $location `
-g $vnetRg `
-n $vnetName `
--address-prefixes $vnetAddressPrefix `
--subnet-name $subnetName `
--subnet-prefixes $subnetAddressPrefix

# Assign Service Principal Role to Vnet
az role assignment create `
--assignee $servicePrincipalClientId `
--role "Reader" `
--scope "/subscriptions/$subscription/resourceGroups/$vnetRg/providers/Microsoft.Network/virtualNetworks/$vnetName"

# Assign Service Principal Role to Subnet
az role assignment create `
--assignee $servicePrincipalClientId `
--role "Contributor" `
--scope "/subscriptions/$subscription/resourceGroups/$vnetRg/providers/Microsoft.Network/virtualNetworks/$vnetName/subnets/$subnetName"
```

### Kubernetes Version
```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"

# Example
$subscription = "My Subscription"
$location = "westeurope"

# Kubernetes Versions
az aks get-versions `
--subscription $subscription `
--location $location `
--output table
```

### Kubernetes Node Size
```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"

# Example
$subscription = "My Subscription"
$location = "westeurope"

# Kubernetes Node Sizes
az vm list-sizes `
--subscription $subscription `
--location $location `
--output table
```

## Create AKS Cluster

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$aksRg = "<AKS RESOURCE GROUP NAME>"
$location = "<LOCATION NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"
$vnetName = "<VNET NAME>"
$subnetName = "<AKS SUBNET NAME>"
$aksName = "<AKS CLUSTER NAME>"
$agentVMSize = "<AKS NODE VM SIZE>"
$agentCount = "<AKS NODE NUMBER>"
$kubernetesVersion = "<AKS KUBERNETES VERSION>"
$maxPods = "<AKS MAX PODS>"
$diskSize = "<AKS NODE DISK SIZE>"
$servicePrincipalClientId = "<AKS SERVICE PRINCIPAL ID>"
$servicePrincipalClientSecret = "<AKS SERVICE PRINCIPAL SECRET>"
$subnetId = "<AKS SUBNET ID>"

# Example
$subscription = "My Subscription"
$aksRg = "rg-aks-c1"
$location = "westeurope"
$vnetRg = "rg-vnet"
$vnetName = "vnet-main"
$subnetName = "subnet-aks-c1"
$aksName = "aks-c1"
$agentVMSize = "Standard_B2s"
$agentCount = "1"
$kubernetesVersion = "1.19.3"
$maxPods = "90"
$diskSize = 100
$servicePrincipalClientId = $client.appId
$servicePrincipalClientSecret = $client.password
$subnetId = $(az network vnet subnet show --resource-group $vnetRg --vnet-name $vnetName --name $subnetName --query id -o tsv)

# Deploy
az aks create `
--name $aksName `
--subscription $subscription `
--resource-group $aksRg `
--location $location `
--node-vm-size $agentVMSize `
--node-count $agentCount `
--kubernetes-version $kubernetesVersion `
--max-pods $maxPods `
--node-osdisk-size $diskSize `
--vnet-subnet-id $subnetId `
--service-principal $servicePrincipalClientId `
--client-secret $servicePrincipalClientSecret `
--generate-ssh-keys
```

## Modify AKS Cluster

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$aksRg = "<AKS RESOURCE GROUP NAME>"
$aksName = "<AKS CLUSTER NAME>"
$kubernetesVersion = "<AKS KUBERNETES VERSION>"

# Example
$subscription = "My Subscription"
$aksRg = "rg-aks-c1"
$aksName = "aks-c1"
$kubernetesVersion = "1.19.6"

# Modify
az aks upgrade `
--name $aksName `
--subscription $subscription `
--resource-group $aksRg `
--kubernetes-version $kubernetesVersion `
--yes
```

## Delete AKS Cluster

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$aksRg = "<AKS RESOURCE GROUP NAME>"
$aksName = "<AKS CLUSTER NAME>"

# Example
$subscription = "My Subscription"
$aksRg = "rg-aks-c1"
$aksName = "aks-c1"

# Delete
az aks delete `
--subscription $subscription `
--resource-group $aksRg `
--name $aksName `
--yes
```

## Clean-up
```powershell
az ad sp delete --id $servicePrincipalClientId
az group delete `
--subscription $subscription `
--name $aksRg `
--yes
az group delete `
--subscription $subscription `
--name $vnetRg `
--yes
```