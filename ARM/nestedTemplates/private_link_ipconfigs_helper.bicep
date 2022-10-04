@description('private DNS zone name')
param privateDnsZoneName string

@description('private endpoint nic ip configuration array')
param privateLinkNicIpConfigs array

@description('private dns zone record template resource URI')
param privateDnsRecordTemplateUri string

module nestedTemplate_private_link_ipconfigs_helper '?' /*TODO: replace with correct path to [parameters('privateDnsRecordTemplateUri')]*/ = [for (item, i) in privateLinkNicIpConfigs: {
  name: 'nestedTemplate-private-link-ipconfigs-helper${i}'
  params: {
    privateDnsZoneName: privateDnsZoneName
    privateLinkNicIpConfig: item
  }
}]