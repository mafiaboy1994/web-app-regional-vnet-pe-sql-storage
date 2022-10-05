
@description('location to deploy app service plan')
param location string

@description('app service plan SKU')
param serverFarmSku object = {
  Tier: 'Standard'
  Name: 'S1'
}

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

@description('project name for deployment')
param projectName string

//var serverFarmName_var = suffix

resource serverFarmName 'Microsoft.Web/serverfarms@2019-08-01' = {
  sku: serverFarmSku
  kind: 'app'
  name: toLower('plan-${projectName}')
  location: location
  tags: tagValues
}

output serverFarmName string = 'plan-${projectName}'
