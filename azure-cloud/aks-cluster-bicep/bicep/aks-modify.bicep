param location string
param aksName string
param kubernetesVersion string

resource aksCluster 'Microsoft.ContainerService/managedClusters@2020-11-01' = {
  name: aksName
  location: location
  properties: {
    kubernetesVersion: kubernetesVersion
  }
}
