## Networking

### Azure Networking

In this tutorial we'll deploy and delete Azure Networking components.

### Tutorial Contents

|Name|Details|
|-----|-----|
|[vnet-2subnets-create.json](arm/vnet-2subnets-create.json)|ARM Template to create Vnet with 2x Subnets|
|[parameters-vnet-2subnets-create.json](arm/parameters-vnet-2subnets-create.json)|Parameters Template to create Vnet with 2x Subnets|
|[vnet-2subnets-delete.json](arm/vnet-2subnets-delete.json)|ARM Template to delete Vnet with 2x Subnets|
|[ip-address-create.json](arm/ip-address-create.json)|ARM Template to create IP Address|
|[parameters-ip-address-create.json](arm/parameters-ip-address-create.json)|Parameters Template to create IP Address|
|[ip-address-delete.json](arm/ip-address-delete.json)|ARM Template to delete IP Address|

## Vnet with 2x Subnets

### Create with ARM Template

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$vnetRg = "rg-vnet"

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $vnetRg

# Deploy Vnet and 2x Subnets
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $vnetRg `
--template-file arm/vnet-2subnets-create.json `
--parameters arm/parameters-vnet-2subnets-create.json
```

### Create with Azure CLI

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"
$vnetName = "<VNET NAME>"
$vnetAddressPrefix = "<VNET ADDRESS SPACE>"
$subnet1Name = "<SUBNET1 NAME>"
$subnet1AddressPrefix = "<SUBNET1 ADDRESS SPACE>"
$subnet2Name = "<SUBNET2 NAME>"
$subnet2AddressPrefix = "<SUBNET2 ADDRESS SPACE>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$vnetRg = "rg-vnet"
$vnetName = "vnet-main"
$vnetAddressPrefix = "10.20.0.0/16"
$subnet1Name = "subnet-1"
$subnet1AddressPrefix = "10.20.10.0/27"
$subnet2Name = "subnet-2"
$subnet2AddressPrefix = "10.20.20.0/27"

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $vnetRg

# Create Vnet
az network vnet create `
--subscription $subscription `
-l $location `
-g $vnetRg `
-n $vnetName `
--address-prefixes $vnetAddressPrefix

# Create Subnet1
az network vnet subnet create `
--subscription $subscription `
-g $vnetRg `
-n $subnet1Name `
--vnet-name $vnetName `
--address-prefixes $subnet1AddressPrefix

# Create Subnet2
az network vnet subnet create `
--subscription $subscription `
-g $vnetRg `
-n $subnet2Name `
--vnet-name $vnetName `
--address-prefixes $subnet2AddressPrefix
```

### Delete with ARM Template

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$vnetRg = "rg-vnet"

# Delete
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $vnetRg `
--template-file arm/vnet-2subnets-delete.json
```

### Delete with Azure CLI

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"
$vnetName = "<VNET NAME>"

# Example
$subscription = "My Subscription"
$vnetRg = "rg-vnet"
$vnetName = "vnet-main"

# Delete
az network vnet delete `
--subscription $subscription `
-g $vnetRg `
-n $vnetName
```

### Clean-up
```powershell
az group delete `
--subscription $subscription `
--name $vnetRg `
--yes
```

## IP Address

### Create with ARM Template

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$ipAddressRg = "<IP ADDRESS RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$ipAddressRg = "rg-ip-address"

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $ipAddressRg

# Deploy Vnet and 2x Subnets
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $ipAddressRg `
--template-file arm/ip-address-create.json `
--parameters arm/parameters-ip-address-create.json
```

### Create with Azure CLI

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$ipAddressRg = "<IP ADDRESS RESOURCE GROUP NAME>"
$ipAddressName = "<IP ADDRESS NAME>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$ipAddressRg = "rg-ip-address"
$ipAddressName = "ip-address-1"

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $ipAddressRg

# Create IP Address
az network public-ip create `
--subscription $subscription `
-l $location `
-g $ipAddressRg `
-n $ipAddressName `
--allocation-method Static `
--sku Standard
```

### Delete with ARM Template

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$ipAddressRg = "<IP ADDRESS RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$ipAddressRg = "rg-ip-address"

# Delete
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $ipAddressRg `
--template-file arm/ip-address-delete.json
```

### Delete with Azure CLI

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$ipAddressRg = "<IP ADDRESS RESOURCE GROUP NAME>"
$ipAddressName = "<IP ADDRESS NAME>"

# Example
$subscription = "My Subscription"
$ipAddressRg = "rg-ip-address"
$ipAddressName = "ip-address-1"

# Delete
az network public-ip delete `
--subscription $subscription `
-g $ipAddressRg `
-n $ipAddressName
```

### Clean-up
```powershell
az group delete `
--subscription $subscription `
--name $ipAddressRg `
--yes
```