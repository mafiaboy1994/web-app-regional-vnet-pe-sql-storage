@description('naming suffix based on resource group name hash')
param suffix string

@description('location to deploy app service plan')
param location string

@description('app service plan SKU')
param serverFarmSku object = {
  Tier: 'Standard'
  Name: 'S1'
}

var serverFarmName_var = 'app-svc-plan-${suffix}'

resource serverFarmName 'Microsoft.Web/serverfarms@2019-08-01' = {
  sku: serverFarmSku
  kind: 'app'
  name: toLower(serverFarmName_var)
  location: location
}

output serverFarmName string = serverFarmName_var