
$projectName = Read-Host -Prompt "Enter Project Name" # Name used to generate for Azure resources
$location = Read-Host -Prompt "Enter a location, i.e. (centralus)"
$companyName = Read-Host -Prompt "Enter Company Name"
$env = Read-Host -Prompt "Enter environment"
$product = Read-Host -Prompt "Products being used?"

$folderPaths = (
    "${home}/nestedTemplates")

$resourceGroupName = "rg-" + $projectName + "-" + $companyName + "-" + $product + "-" + $env + "-" + $location
$storageAccountName = "stdeployment" + $projectName  + $env
$containerName = "templates"

$mainTemplateURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/azuredeploy.json"
$mainTemplateParamsURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/azuredeploy.parameters.json"
$appSvcPlanURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/app_svc_plan.json"
$appjsonDeployURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/app.json"
$dnsRecordURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/dns_record.json"
$privateDnsURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/private_dns.json"
$privateLinkIpConfigsHelperURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/private_link_ipconfigs_helper.json"
$privateLinkIpConfigsURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/private_link_ipconfigs.json"
$privateLinkURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/private_link.json"
$sqldbURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/sqldb.json"
$storageURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/storage.json"
$vnetPeeringURL = "https://raw.githubusercontent.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/main/nestedtemplates/vnet_peering.json"
$vnetsURL = "https://github.com/mafiaboy1994/web-app-regional-vnet-pe-sql-storage/blob/main/nestedtemplates/vnets.json"


$mainFileName = "azuredeploy.json" # File name used for downloading and uploading the main template.Add-PSSnapin
$mainParamsFileName = "azuredeploy.parameters.json"
$appSvcPlanFileName = "app_svc_plan.json"
$appjsonFileName = "app.json"
$dnsRecordFileName = "dns_record.json"
$privateDnsFileName = "private_dns.json"
$privateLinkIpConfigsHelperFileName = "private_link_ipconfigs_helper.json"
$privateLinkIpConfigsFileName = "private_link_ipconfigs.json"
$privateLinkFileName = "private_link.json"
$sqldbFileName = "sqldb.json"
$storageFileName = "storage.json"
$vnetPeeringFileName = "vnet_peering.json"
$vnetsFileName = "vnets.json"



# Creating required folders if not already setup in $home
foreach($paths in $folderPaths){
    if(Test-Path -Path $paths){
    }
    else{
        mkdir $paths > $null
    }
}

#Download templates
Invoke-WebRequest -Uri $mainTemplateURL -OutFile "$home/$mainFileName"
Invoke-WebRequest -Uri $mainTemplateParamsURL -OutFile "$home/$mainParamsFileName"
Invoke-WebRequest -uri $appSvcPlanURL -OutFile "$home/nestedtemplates/$appSvcPlanFileName"
Invoke-WebRequest -Uri $appjsonDeployURL -OutFile "$home/nestedtemplates/$appjsonFileName"
Invoke-WebRequest -Uri $dnsRecordURL -OutFile "$home/nestedtemplates/$dnsRecordFileName"
Invoke-WebRequest -Uri $privateDnsURL -OutFile "$home/nestedtemplates/$privateDnsFileName"
Invoke-WebRequest -Uri $privateLinkIpConfigsHelperURL -OutFile "$home/nestedtemplates/$privateLinkIpConfigsHelperFileName"
Invoke-WebRequest -Uri $privateLinkIpConfigsURL -OutFile "$home/nestedtemplates/$privateLinkIpConfigsFileName"
Invoke-WebRequest -uri $privateLinkURL -OutFile "$home/nestedtemplates/$privateLinkFileName"
Invoke-WebRequest -Uri $sqldbURL -OutFile "$home/nestedtemplates/$sqldbFileName "
Invoke-WebRequest -Uri $storageURL -OutFile "$home/nestedtemplates/$storageFileName"
Invoke-WebRequest -Uri $vnetPeeringURL -OutFile "$home/nestedtemplates/$vnetPeeringFileName"
Invoke-WebRequest -uri $vnetsURL -OutFile "$home/nestedtemplates/$vnetsFileName"




#Storage Group RG
New-AzResourceGroup -Name $resourceGroupName -Location $location

#Storage Account
$storageAccount = New-AzStorageAccount `
-ResourceGroupName $resourceGroupName `
-Name $storageAccountName `
-Location $location `
-SkuName "Standard_GRS"

$key = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName).Value[0]
#$context = $storageAccount.Context
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $key
#Create a container
New-AzStorageContainer -Name $containerName -Context $context -Permission Container

Write-Host "Press [ENTER] to continue....."

#Upload Templates
Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/$mainFileName" `
-Blob $mainFileName `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/$mainParamsFileName" `
-Blob $mainParamsFileName `
-Context $context -Force

# Nested Templates Upload
Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$appSvcPlanFileName " `
-Blob "nestedtemplates/${appSvcPlanFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$appjsonFileName" `
-Blob "nestedtemplates/${appjsonFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$dnsRecordFileName" `
-Blob "nestedtemplates/${dnsRecordFileName}" `
-Context $context -Force



Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$privateDnsFileName" `
-Blob "nestedtemplates/${privateDnsFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$privateLinkIpConfigsHelperFileName" `
-Blob "nestedtemplates/${privateLinkIpConfigsHelperFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$privateLinkIpConfigsFileName" `
-Blob "nestedtemplates/${privateLinkIpConfigsFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$privateLinkFileName" `
-Blob "nestedtemplates/${privateLinkFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$sqldbFileName" `
-Blob "nestedtemplates/${sqldbFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$storageFileName" `
-Blob "nestedtemplates/${storageFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$vnetPeeringFileName" `
-Blob "nestedtemplates/${vnetPeeringFileName}" `
-Context $context -Force

Set-AzStorageBlobContent `
-Container $containerName `
-File "$home/nestedtemplates/$vnetsFileName" `
-Blob "nestedtemplates/${vnetsFileName}" `
-Context $context -Force


Write-Host "Press [ENTER] to continue....."



$mainTemplateUri = $context.BlobEndPoint + "$containerName/azuredeploy.json"
$mainTemplateParamsUri = $context.BlobEndPoint + "$containerName/azuredeploy.parameters.json"
$sasToken = New-AzStorageContainerSASToken `
-Context $context `
-Container $containerName `
-Permission r `
-ExpiryTime (Get-Date).AddHours(2.0)

$newSas = $sasToken.substring(1)

New-AzResourceGroupDeployment `
-Name DeployMainTemplate `
-ResourceGroupName $resourceGroupName `
-TemplateUri $mainTemplateUri `
-TemplateParameterUri $mainTemplateParamsUri `
-QueryString $newSas `
-Verbose `
-DeploymentDebugLogLevel All



