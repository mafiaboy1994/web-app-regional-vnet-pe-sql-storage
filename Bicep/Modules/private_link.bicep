
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

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

@description('environment for deployment')
param env string

@description('Company name for deployment')
param companyName string


var prefix = guid(resourceType)
var privateEndpointName_var = 'pe-${prefix}--${companyName}-${env}-${location}'
var privateEndpointConnectionName = 'pep-cxn-${prefix}'

resource privateEndpointName 'Microsoft.Network/privateEndpoints@2020-08-01' = {
  name: privateEndpointName_var
  location: location
  tags: tagValues
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
