## Application Gateway

### Azure Application Gateway

In this tutorial we'll deploy and delete Azure Application Gateway.

### Tutorial Contents

|Name|Details|
|-----|-----|
|[application-gateway-create.json](arm/application-gateway-create.json)|ARM Template to create Application Gateway|
|[parameters-application-gateway-create.json](arm/parameters-application-gateway-create.json)|Parameters Template to create Application Gateway|
|[application-gateway-delete.json](arm/application-gateway-delete.json)|ARM Template to delete Application Gateway|

## Dependencies

The Azure Application Gateway depends on several Azure resources or resource versions, as defined below. You might have some of these already created or defined on your Azure infrastructure. If not, please use the code snippets below to create these prior to provisioning your Azure Application Gateway.

|Resource|Details|
|-----|-----|
|Public IP Address|IP Address needs to be assigned to the Application Gateway to allow access to your backed applications or services.|
|Application Gateway Resource Group|This is simply a container for your Application Gateway resources, and it needs to be created prior to provisioning your Application Gateway.|
|Networking|You need to have Vnet in place and a dedicated Subnet for your Application Gateway created on that Vnet.|
|Backend IP Address|The Application Gateway needs to resolve calls to somewhere in your backed infrastructure. We'll use IP address here but you can also use FQDN records.|

### Public IP Address

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

### Application Gateway Resource Group

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$location = "<LOCATION NAME>"
$agRg = "<APPLICATION GATEWAY RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$location = "westeurope"
$agRg = "rg-ag"

# Create Resource Group
az group create `
--subscription $subscription `
-l $location `
-n $agRg
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

# Example
$subscription = "My Subscription"
$location = "westeurope"
$vnetRg = "rg-vnet"
$vnetName = "vnet-main"
$vnetAddressPrefix = "10.20.0.0/16"
$subnetName = "subnet-ag"
$subnetAddressPrefix = "10.20.10.0/24"

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
```

### Backend IP Address

This can be any IP Address for the purposes of this tutorial. However, in real life examples you'll need this to resolve to an application or a service.

```powershell
# Variables
$backendIpAddress = "<BACKEND IP ADDRESS>"

# Example
$backendIpAddress = "10.10.10.10"
```

## Create Azure Application Gateway

### With Parameters File

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$agRg = "<APPLICATION GATEWAY RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$agRg = "rg-ag"

# Deploy
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $agRg `
--template-file arm/application-gateway-create.json `
--parameters arm/parameters-application-gateway-create.json
```

### With Parameters Inline

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$agRg = "<APPLICATION GATEWAY RESOURCE GROUP NAME>"
$location = "<LOCATION NAME>"
$agName = "<APPLICATION GATEWAY NAME>"
$ipAddressName = "<FRONTEND IP ADDRESS NAME>"
$ipAddressRg = "<FRONTEND IP ADDRESS RESOURCE GROUP NAME>"
$vnetName = "<VNET NAME>"
$vnetRg = "<VNET RESOURCE GROUP NAME>"
$subnetName = "<APPLICATION GATEWAY SUBNET NAME>"
$backendIpAddress = "<BACKEND IP ADDRESS>"

# Example
$subscription = "My Subscription"
$agRg = "rg-ag"
$location = "westeurope"
$agName = "ag-main"
$ipAddressName = "ip-address-1"
$ipAddressRg = "rg-ip-address"
$vnetName = "vnet-main"
$vnetRg = "rg-vnet"
$subnetName = "subnet-ag"
$backendIpAddress = "10.10.10.10"

# Deploy
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $agRg `
--template-file arm/application-gateway-create.json `
--parameters `
location=$location `
agName=$agName `
ipAddressName=$ipAddressName `
ipAddressRg=$ipAddressRg `
vnetName=$vnetName `
vnetRg=$vnetRg `
subnetName=$subnetName `
backendIpAddress=$backendIpAddress
```

## Delete Azure Application Gateway

### With ARM Template

```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$agRg = "<APPLICATION GATEWAY RESOURCE GROUP NAME>"

# Example
$subscription = "My Subscription"
$agRg = "rg-ag"

# Delete
az group deployment create `
--mode Complete `
--subscription $subscription `
--resource-group $agRg `
--template-file arm/application-gateway-delete.json
```

### With Azure CLI
```powershell
# Variables
$subscription = "<AZURE SUBSCRIPTION ID or NAME>"
$agRg = "<APPLICATION GATEWAY RESOURCE GROUP NAME>"
$agName = "<APPLICATION GATEWAY NAME>"

# Example
$subscription = "My Subscription"
$agRg = "rg-ag"
$agName = "ag-main"

# Delete
az network application-gateway delete `
--subscription $subscription `
--resource-group $agRg `
--name $agName
```

## Clean-up
```powershell
az group delete `
--subscription $subscription `
--name $agRg `
--yes
az group delete `
--subscription $subscription `
--name $ipAddressRg `
--yes
az group delete `
--subscription $subscription `
--name $vnetRg `
--yes
```