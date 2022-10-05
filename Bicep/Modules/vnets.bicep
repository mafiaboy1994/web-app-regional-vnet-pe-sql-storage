@description('virtual network name sufix based on resource group hash')
param suffix string

@description('location to dpeloy the vnet')
param location string

@description('environment for deployment')
param env string


@description('JSON input object defining Vnets and subnets. The first network in the array is assumed to be the hub netwkr and will be peered to all subsequent networks')
param vNets object

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

@description('Company name for deployment')
param companyName string


var subnets = [for i in range(0, length(vNets.subnets)): {
  name: 'snet-${vNets.subnets[i].name}'
  properties: {
    addressPrefix: vNets.subnets[i].addressPrefix
    delegations: ((vNets.subnets[i].delegations == json('null')) ? json('null') : vNets.subnets[i].delegations)
    privateEndpointNetworkPolicies: ((vNets.subnets[i].privateEndpointNetworkPolicies == json('null')) ? json('null') : vNets.subnets[i].privateEndpointNetworkPolicies)
    privateLinkServiceNetworkPolicies: ((vNets.subnets[i].privateLinkServiceNetworkPolicies == json('null')) ? json('null') : vNets.subnets[i].privateLinkServiceNetworkPolicies)
    routeTable: ((vNets.subnets[i].udrName == json('null')) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/routeTables', '${vNets.subnets[i].udrName}-rt-${suffix}')}"}"}'))
    networkSecurityGroup: ((vNets.subnets[i].nsgName == json('null')) ? json('null') : json('{"id": "${resourceId('Microsoft.Network/networkSecurityGroups', 'nsg-snet-${vNets.subnets[i].nsgName}${suffix}')}"}"}'))
  }
  id: resourceId('Microsoft.Network/virtualNetworks/subnets/', 'vnet-${vNets.name}-${suffix}', 'snet-${vNets.subnets[i].name}')
}]

var nsgSecurityRules = json(loadTextContent('../params/nsgRules.json')).securityRules

resource nsgResource 'Microsoft.Network/networkSecurityGroups@2022-01-01' = [for nsgs in vNets.subnets: {
  name: 'nsg-snet-${nsgs.name}-${companyName}-${env}-${location}'
  location: location
  properties: {
    securityRules: nsgSecurityRules
  }
}]

resource vNets_name_suffix 'Microsoft.Network/virtualNetworks@2020-08-01' = {
  name: 'vnet-${vNets.name}-${suffix}'
  location: location
  tags: tagValues
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
