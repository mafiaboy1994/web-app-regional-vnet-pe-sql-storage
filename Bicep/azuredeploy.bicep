//@description('The base URI where artifacts required by this template are located including a trailing \'/\'')
//param _artifactsLocation string = deployment().properties.templateLink.uri

//@description('The sasToken required to access _artifactsLocation.  When the template is deployed using the accompanying scripts, a sasToken will be automatically generated. Use the defaultValue if the staging location is not secured.')
//@secure()
//param _artifactsLocationSasToken string = ''

@description('deployment location')
param location string = resourceGroup().location

@description('environment for deployment')
param env string

@description('Company name for deployment')
param companyName string

@description('Products used for deployment')
param product string

@description('project name for deployment')
param projectName string

@description('current date for the deployment records. Do not overwrite')
param currentDate string = utcNow('yyyy-dd-mm')

@description('unique web app name')
param webAppName string = projectName
//param webAppName string = uniqueString(subscription().id, resourceGroup().id)

@description('Azure SQL DB administrator login name')
param sqlAdministratorLoginName string

@description('Azure SQL DB administrator password')
@secure()
param sqlAdministratorLoginPassword string

@description('JSON object describing virtual networks & subnets')
param vNets array

var suffix = substring(replace(guid(resourceGroup().id), '-', ''), 0, 6)
var appName = webAppName
var storagePrivateDnsZoneName = 'privatelink.blob.${environment().suffixes.storage}'
var sqlPrivateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var sqlDatabaseName = projectName
var storageContainerName = 'mycontainer'
var storageGroupType = 'blob'
var sqlGroupType = 'sqlServer'


var tagValues = {
  createdBy: 'Elijah Wright'
  company: companyName
  DateCreated: currentDate
  environment: env
  product: product
}

//var vnetNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/vnets.json${_artifactsLocationSasToken}')
//var vnetPeeringNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/vnet_peering.json${_artifactsLocationSasToken}')
//var appServicePlanNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/app_svc_plan.json${_artifactsLocationSasToken}')
//var appNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/app.json${_artifactsLocationSasToken}')
//var sqlNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/sqldb.json${_artifactsLocationSasToken}')
//var privateLinkNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/private_link.json${_artifactsLocationSasToken}')
//var storageNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/storage.json${_artifactsLocationSasToken}')
//var privateDnsNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/private_dns.json${_artifactsLocationSasToken}')
//var privateDnsRecordNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/dns_record.json${_artifactsLocationSasToken}')
//var privateLinkIpConfigsNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/private_link_ipconfigs.json${_artifactsLocationSasToken}')
//var privateLinkIpConfigsHelperNestedTemplateUri = uri(_artifactsLocation, 'nestedtemplates/private_link_ipconfigs_helper.json${_artifactsLocationSasToken}')

module vnetModule 'Modules/vnets.bicep' = [for (network, i) in vNets: {
  name: 'vnets-${i}'
  params: {
    env: env
    location: location
    vNets: network
    tagValues: tagValues
    companyName: companyName
    projectName:projectName
  }
}]

module vnetPeeringsModule 'Modules/vnet_peering.bicep' = {
  name: 'vnetPeerings'
  params: {
    location: location
    vNets: vNets
    companyName:companyName
    env:env
    projectName:projectName
  }
  dependsOn: [
    vnetModule
  ]
}

module appServicePlanModule 'Modules/app_svc_plan.bicep' = {
  name: 'appServicePlans'
  params: {
    location: location
    serverFarmSku: {
      Tier: 'Standard'
      Name: 'S1'
    }
    tagValues: tagValues
    projectName: projectName
  }
  dependsOn: [
    vnetModule
  ]
}

module appServiceModule 'Modules/app.bicep'  = {
  name: 'appServices'
  params: {
    location: location
    hostingPlanName: appServicePlanModule.outputs.serverFarmName
    subnet: vnetModule[1].outputs.subnetResourceIds[0].id
    appName: appName
    ipAddressRestriction: [
      '0.0.0.0/32'
    ]
    tagValues: tagValues
    companyName:companyName
    env:env
  }
}

module sqlDBModule 'Modules/sqldb.bicep' /*TODO: replace with correct path to [variables('sqlNestedTemplateUri')]*/ = {
  name: 'sqldbs'
  params: {
    suffix: suffix
    location: location
    sqlAdministratorLogin: sqlAdministratorLoginName
    sqlAdministratorLoginPassword: sqlAdministratorLoginPassword
    databaseName: sqlDatabaseName
    tagValues: tagValues
    projectName:projectName
  }
  dependsOn: [
    vnetModule
  ]
}

module privateLinkModule 'Modules/private_link.bicep'  /*TODO: replace with correct path to [variables('privateLinkNestedTemplateUri')]*/ = {
  name: 'sqldb-private-link'
  params: {
    location: location
    resourceType: 'Microsoft.Sql/servers'
    resourceName: sqlDBModule.outputs.sqlServerName
    groupType: sqlGroupType
    subnet: vnetModule[0].outputs.subnetResourceIds[0].id
    tagValues: tagValues
  }
}

module storageModule 'Modules/storage.bicep' /*TODO: replace with correct path to [variables('storageNestedTemplateUri')]*/ = {
  name: 'storage-accounts'
  params: {
    location: location
    containerName: storageContainerName
    defaultNetworkAccessAction: 'Deny'
    tagValues: tagValues
    companyName:companyName
    env:env
  }
  dependsOn: [
    vnetModule
  ]
}

module StoragePrivateLinkModule 'Modules/private_link.bicep' /*TODO: replace with correct path to [variables('privateLinkNestedTemplateUri')]*/ = {
  name: 'storage-private-link'
  params: {
    location: location
    resourceType: 'Microsoft.Storage/storageAccounts'
    resourceName: storageModule.outputs.storageAccountName
    groupType: storageGroupType
    subnet: vnetModule[0].outputs.subnetResourceIds[0].id
    tagValues: tagValues
  }
}

module storageDNSSpokeLinkModule 'Modules/private_dns.bicep' /*TODO: replace with correct path to [variables('privateDnsNestedTemplateUri')]*/ = {
  name: 'storage-private-dns-spoke-link'
  params: {
    privateDnsZoneName: storagePrivateDnsZoneName
    virtualNetworkName: vnetModule[1].outputs.virtualNetworkName
    tagValues: tagValues
    companyName:companyName
    env:env
    projectName:projectName
    location:location
  }
  dependsOn: [
    StoragePrivateLinkModule
  ]
}

module storageDNSHubLinkModule  'Modules/private_dns.bicep' = {
  name: 'storage-private-dns-hub-link'
  params: {
    privateDnsZoneName: storagePrivateDnsZoneName
    virtualNetworkName: vnetModule[0].outputs.virtualNetworkName
    tagValues: tagValues
    companyName:companyName
    env:env
    projectName:projectName
    location:location
  }
  dependsOn: [
    StoragePrivateLinkModule
    storageDNSSpokeLinkModule
  ]
}

module storagePrivateLinkIpConfigsModule 'Modules/private_link_ipconfigs.bicep' /*TODO: replace with correct path to [variables('privateLinkIpConfigsNestedTemplateUri')]*/ = {
  name: 'storage-private-link-ipconfigs'
  params: {
    privateDnsZoneName: storagePrivateDnsZoneName
    location: location
    privateLinkNicResource: StoragePrivateLinkModule.outputs.privateLinkNicResource
    //privateDnsRecordTemplateUri: privateLinkModule
    //privateLinkNicIpConfigTemplateUri: storagePrivateLinkIpConfigsModule
  }
  dependsOn: [
    StoragePrivateLinkModule
    storageDNSHubLinkModule
  ]
}

module sqlDBPrivateDNSSpokeLinkModule 'Modules/private_dns.bicep' /*TODO: replace with correct path to [variables('privateDnsNestedTemplateUri')]*/ = {
  name: 'sqldb-private-dns-spoke-link'
  params: {
    privateDnsZoneName: sqlPrivateDnsZoneName
    virtualNetworkName: vnetModule[1].outputs.virtualNetworkName
    tagValues: tagValues
    companyName:companyName
    env:env
    projectName:projectName
    location:location
  }
  dependsOn: [
    privateLinkModule
  ]
}

module sqlDBPrivateDNSHubLinkModule 'Modules/private_dns.bicep' /*TODO: replace with correct path to [variables('privateDnsNestedTemplateUri')]*/ = {
  name: 'sqldb-private-dns-hub-link'
  params: {
    privateDnsZoneName: sqlPrivateDnsZoneName
    virtualNetworkName: vnetModule[0].outputs.virtualNetworkName
    tagValues: tagValues
    companyName:companyName
    env:env
    projectName:projectName
    location:location
  }
  dependsOn: [
    sqlDBModule
    sqlDBPrivateDNSSpokeLinkModule
  ]
}

module sqlDBPrivateLinkIpconfigsModule 'Modules/private_link_ipconfigs.bicep' /*TODO: replace with correct path to [variables('privateLinkIpConfigsNestedTemplateUri')]*/ = {
  name: 'sqldb-private-link-ipconfigs'
  params: {
    privateDnsZoneName: sqlPrivateDnsZoneName
    location: location
    privateLinkNicResource: privateLinkModule.outputs.privateLinkNicResource
  }
  dependsOn: [
    sqlDBPrivateDNSHubLinkModule
  ]
}
