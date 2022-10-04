@description('private dns zone name')
param privateDnsZoneName string

@description('private endpoint Nic ipConfigurations array resource id')
param privateLinkNicResource string

//@description('ip configurations template resource URI')
//param privateLinkNicIpConfigTemplateUri string

//@description('private dns record template resource URI')
//param privateDnsRecordTemplateUri string

param location string

module private_link_ipconfigs 'private_link_ipconfigs_helper.bicep' /*TODO: replace with correct path to [parameters('privateLinkNicIpConfigTemplateUri')]*/ = {
  name: 'private-link-ipconfigs'
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateLinkNicIpConfigs: reference(privateLinkNicResource, '2019-11-01').ipConfigurations
    location: location
    //privateDnsRecordTemplateUri: privateDnsRecordTemplateUri
  }
}
