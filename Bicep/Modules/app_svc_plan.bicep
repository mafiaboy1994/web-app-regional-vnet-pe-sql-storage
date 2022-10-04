@description('naming suffix based on resource group name hash')
param suffix string

@description('location to deploy app service plan')
param location string

@description('app service plan SKU')
param serverFarmSku object = {
  Tier: 'Standard'
  Name: 'S1'
}

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

var serverFarmName_var = suffix

resource serverFarmName 'Microsoft.Web/serverfarms@2019-08-01' = {
  sku: serverFarmSku
  kind: 'app'
  name: toLower('plan-${serverFarmName_var}')
  location: location
  tags: tagValues
}

output serverFarmName string = 'plan-${serverFarmName_var}'
