@description('naming suffix based on resource group name hash')
param suffix string

@description('location to deploy the storage account')
param location string

@description('array of JSON virtual network objects')
param vNets array

resource vNets_0_name_suffix_peering_to_vnets_1_name_suffix 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2018-11-01' = [for i in range(0, (length(vNets) - 1)): {
  name: '${vNets[0].name}-${suffix}/peering-to-${vNets[(i + 1)].name}-${suffix}'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', '${vNets[(i + 1)].name}-${suffix}')
    }
  }
}]

resource vNets_1_name_suffix_peering_to_vNets_0_name_suffix 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2018-11-01' = [for i in range(0, (length(vNets) - 1)): {
  name: '${vNets[(i + 1)].name}-${suffix}/peering-to-${vNets[0].name}-${suffix}'
  location: location
  properties: {
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
    remoteVirtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', '${vNets[0].name}-${suffix}')
    }
  }
}]