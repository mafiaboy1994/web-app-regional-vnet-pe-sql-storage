@description('private dns zone name')
param privateDnsZoneName string

@description('virtual network name')
param virtualNetworkName string

@description('controls whether the dns zone will automatically register DNS records for resources in the virtual network')
param enableVmRegistration bool = false

resource privateDnsZoneName_resource 'Microsoft.Network/privateDnsZones@2020-01-01' = {
  name: privateDnsZoneName
  location: 'global'
}

resource privateDnsZoneName_privateDnsZoneName_virtualNetworkName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-01-01' = {
  parent: privateDnsZoneName_resource
  name: 'pdnsz-link-${privateDnsZoneName}-vnet-${virtualNetworkName}'
  location: 'global'
  properties: {
    registrationEnabled: enableVmRegistration
    virtualNetwork: {
      id: resourceId('Microsoft.Network/virtualNetworks', 'vnet-${virtualNetworkName}')
    }
  }
}
