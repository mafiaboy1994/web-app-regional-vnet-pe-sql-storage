@description('naming suffix based on resource group name hash')
param suffix string

@description('location to deploy the Azure SQL Db server')
param location string

@description('Azure SQL Db server administrator login name')
param sqlAdministratorLogin string

@description('Azure SQL Db server administrator login password')
@secure()
param sqlAdministratorLoginPassword string

@description('Azure SQL database name')
param databaseName string

@description('Azure SQL database edition')
param databaseEdition string = 'Basic'

@description('Azure SQL database collation type')
param databaseCollation string = 'SQL_Latin1_General_CP1_CI_AS'

@description('Azure SQL database service objective type name')
param databaseServiceObjectiveName string = 'Basic'

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

@description('project name for deployment')
param projectName string

var sqlServerName_var = projectName

resource sqlServerName 'Microsoft.Sql/servers@2020-02-02-preview' = {
  name: 'sql-${sqlServerName_var}'
  location: location
  tags: tagValues
  properties: {
    administratorLogin: sqlAdministratorLogin
    administratorLoginPassword: sqlAdministratorLoginPassword
    version: '12.0'
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlServerName_databaseName 'Microsoft.Sql/servers/databases@2020-02-02-preview' = {
  parent: sqlServerName
  name: 'sqldb-${databaseName}'
  location: location
  tags: tagValues
  properties: {
    edition: databaseEdition
    collation: databaseCollation
    requestedServiceObjectiveName: databaseServiceObjectiveName
  }
}

output sqlServerFqdn string = sqlServerName.properties.fullyQualifiedDomainName
output sqlServerName string = 'sql-${sqlServerName_var}'
output databaseName string = 'sqldb-${databaseName}'
