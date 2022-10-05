@description('private dns zone name')
param privateDnsZoneName string

@description('virtual network name')
param virtualNetworkName string

@description('controls whether the dns zone will automatically register DNS records for resources in the virtual network')
param enableVmRegistration bool = false

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

@description('environment for deployment')
param env string

@description('Company name for deployment')
param companyName string

@description('project name for deployment')
param projectName string

@description('deployment location')
param location string = resourceGroup().location

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
      id: resourceId('Microsoft.Network/virtualNetworks', 'vnet-${projectName}-${virtualNetworkName}-${companyName}-${env}-${location}')
    }
  }
  tags: tagValues
}
