

@description('location to deploy the storage account')
param location string

@description('array of JSON virtual network objects')
param vNets array

@description('project name for deployment')
param projectName string

@description('environment for deployment')
param env string

@description('Company name for deployment')
param companyName string

resource vNets_0_name_suffix_peering_to_vnets_1_name_suffix 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2018-11-01' = [for i in range(0, (length(vNets) - 1)): {
  name: 'vnet-${projectName}-${vNets[0].name}-${companyName}-${env}-${location}/peering-to-vnet-${projectName}-${vNets[(i + 1)].name}-${companyName}-${env}-${location}'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', 'vnet-${projectName}-${vNets[(i + 1)].name}-${companyName}-${env}-${location}')
      //resourceId('Microsoft.Network/virtualNetworks', 'vnet-${vNets[(i + 1)].name}')
    }
  }
}]

resource vNets_1_name_suffix_peering_to_vNets_0_name_suffix 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2018-11-01' = [for i in range(0, (length(vNets) - 1)): {
  name: 'vnet-${projectName}-${vNets[(i + 1)].name}-${companyName}-${env}-${location}/peering-to-vnet-${projectName}-${vNets[0].name}-${companyName}-${env}-${location}'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', 'vnet-${projectName}-${vNets[0].name}-${companyName}-${env}-${location}')
      //resourceId('Microsoft.Network/virtualNetworks', 'vnet-${vNets[0].name}')
    }
  }
}]
