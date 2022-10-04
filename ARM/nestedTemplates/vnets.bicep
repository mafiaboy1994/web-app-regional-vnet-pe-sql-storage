@description('virtual network name sufix based on resource group hash')
param suffix string

@description('location to dpeloy the vnet')
param location string

@description('JSON input object defining Vnets and subnets. The first network in the array is assumed to be the hub netwkr and will be peered to all subsequent networks')
param vNets object

var subnets = [for i in range(0, length(vNets.subnets)): {
  name: vNets.subnets[i].name
  properties: {
    addressPrefix: vNets.subnets[i].addressPrefix
    delegations: ((vNets.subnets[i].delegations == json('null')) ? json('null') : vNets.subnets[i].delegations)
    privateEndpointNetworkPolicies: ((vNets.subnets[i].privateEndpointNetworkPolicies == json('null')) ? json('null') : vNets.subnets[i].privateEndpointNetworkPolicies)
    privateLinkServiceNetworkPolicies: ((vNets.subnets[i].privateLinkServiceNetworkPolicies == json('null')) ? json('null') : vNets.subnets[i].privateLinkServiceNetworkPolicies)
    routeTable: ((vNets.subnets[i].udrName == json('null')) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/routeTables', '${vNets.subnets[i].udrName}-rt-${suffix}')}"}"}'))
    networkSecurityGroup: ((vNets.subnets[i].nsgName == json('null')) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', '${vNets.subnets[i].nsgName}-nsg-${suffix}')}"}"}'))
  }
  id: resourceId('Microsoft.Network/virtualNetworks/subnets/', '${vNets.name}-${suffix}', vNets.subnets[i].name)
}]

resource vNets_name_suffix 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: '${vNets.name}-${suffix}'
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: vNets.addressPrefixes
    }
    subnets: subnets
  }
}

output subnetResourceIds array = subnets
output vnetRef string = vNets_name_suffix.id
output virtualNetworkName string = '${vNets.name}-${suffix}'