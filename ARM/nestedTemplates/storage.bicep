@description('naming suffix based on resource group name hash')
param suffix string

@description('location to deploy the storage account')
param location string

@description('storage account SKU')
param storageSku string = 'Standard_LRS'

@description('storage account kind')
param storageKind string = 'StorageV2'

@description('storage account container name')
param containerName string

@description('allor or deny internet access to storage account')
@allowed([
  'Allow'
  'Deny'
])
param defaultNetworkAccessAction string = 'Allow'

var storageAccountName_var = suffix

resource storageAccountName 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'st${storageAccountName_var}'
  sku: {
    name: storageSku
  }
  kind: storageKind
  location: location
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: defaultNetworkAccessAction
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

resource storageAccountName_default_containerName 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
  name: 'st${storageAccountName_var}/default/${containerName}'
  dependsOn: [
    storageAccountName
  ]
}

output storageAccountName string = storageAccountName_var
//output storageContainerUri string = concat(storageAccountName.properties.primaryEndpoints.blob, containerName)
output storageContainerUri string = '${storageAccountName.properties.primaryEndpoints.blob}, ${containerName}'
output containerName string = containerName
