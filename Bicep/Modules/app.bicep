@description('name of app service web app (must be globally unique)')
param appName string

@description('location to deploy app service web app')
param location string

@description('environment for deployment')
param env string

@description('Company name for deployment')
param companyName string

@description('name of app service hosting plan')
param hostingPlanName string

@description('project name for deployment')
param projectName string

@description('ip address restrictions for web app')
param ipAddressRestriction array = [
  {
    ipAddress: '0.0.0.0/32'
  }
]

@description('Tag val;ues to be applied to resources in this deployment')
param tagValues object

@description('resource id of subnet to use for app service reginal vnet integration')
param subnet string

resource appName_resource 'Microsoft.Web/sites@2019-08-01' = {
  name: 'app-${toLower(appName)}-${companyName}-${env}-${location}'
  location: location
  tags: tagValues
  properties: {
    //name: toLower(appName)
    serverFarmId: resourceId('Microsoft.Web/serverfarms', hostingPlanName)
    siteConfig: {
      appSettings: [
        {
          name: 'WEBSITE_VNET_ROUTE_ALL'
          value: 1
        }
        {
          name: 'WEBSITE_DNS_SERVER'
          value: '168.63.129.16'
        }
      ]
    }
  }
}

resource appName_web 'Microsoft.Web/sites/config@2019-08-01' = {
  name: 'app-${toLower(appName)}/web'
  properties: {
    ipSecurityRestrictions: ipAddressRestriction
  }
  dependsOn: [
    appName_resource
  ]
}

resource appName_virtualNetwork 'Microsoft.Web/sites/networkConfig@2019-08-01' = {
  name: 'app-${toLower(appName)}/virtualNetwork'
  location: location
  properties: {
    subnetResourceId: subnet
    swiftSupported: true
  }
  dependsOn: [
    appName_resource
  ]
}

output appName string = appName
