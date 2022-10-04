@description('naming suffix based on resource group name hash')
param suffix string

@description('location to deploy private link endpoint web app')
param location string

@description(' private link resource type')
param resourceType string

@description('private link resource name')
param resourceName string

@description('private link resource group id')
param groupType string

@description('resource id of private link subnet')
param subnet string

var prefix = guid(resourceType)
var privateEndpointName_var = '${prefix}-pl-${suffix}'
var privateEndpointConnectionName = '${prefix}-pep-cxn-${suffix}'

resource privateEndpointName 'Microsoft.Network/privateEndpoints@2020-08-01' = {
  name: privateEndpointName_var
  location: location
  properties: {
    privateLinkServiceConnections: [
      {
        name: privateEndpointConnectionName
        properties: {
          privateLinkServiceId: resourceId(resourceType, resourceName)
          groupIds: [
            groupType
          ]
        }
      }
    ]
    subnet: {
      id: subnet
    }
  }
}

output privateLinkNicResource string = reference(privateEndpointName.id, '2019-11-01').networkInterfaces[0].id
output privateEndpointName string = privateEndpointName_var
