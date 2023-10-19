param location string
param vnetRg string
param vnetName string
param subnetName string
param aksName string
param agentVMSize string
param agentCount int
param kubernetesVersion string
param maxPods int
@secure()
param servicePrincipalClientId string
@secure()
param servicePrincipalClientSecret string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2020-11-01' = {
  name: aksName
  location: location
  properties: {
    kubernetesVersion: kubernetesVersion
    dnsPrefix: aksName
    enableRBAC: false
    addonProfiles: {
      httpApplicationRouting: {
        enabled: false
      }
    }
    agentPoolProfiles: [
      {
        name: 'agentpool'
        count: agentCount
        vmSize: agentVMSize
        osDiskSizeGB: 100
        osDiskType: 'Managed'
        vnetSubnetID: resourceId(vnetRg, 'Microsoft.Network/virtualNetworks/subnets', vnetName, subnetName)
        maxPods: maxPods
        type: 'AvailabilitySet'
        orchestratorVersion: kubernetesVersion
        mode: 'User'
        osType: 'Linux'
      }
    ]
    servicePrincipalProfile: {
      clientId: servicePrincipalClientId
      secret: servicePrincipalClientSecret
    }
    networkProfile: {
      networkPlugin: 'kubenet'
      loadBalancerSku: 'basic'
    }
  }
}
