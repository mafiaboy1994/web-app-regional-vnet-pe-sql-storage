
$projectName = Read-Host "Project Name?"
$location = Read-Host "Location?"
$env = Read-Host "Environment?"
$companyName = Read-Host "Company Name?"
$product = Read-Host "Products used in deployment?"



$resourceGroup = New-AzResourceGroup `
-Name "rg-$projectName-$env-$companyName-$product-$location"
-location $location

New-AzResourceGroupDeployment `
-ResourceGroupName $resourceGroup.ResourceGroupName `
-TemplateParameterFile .\Bicep\params\azuredeploy.parameters.json `
-TemplateFile .\Bicep\azuredeploy.bicep
-env $env `
-companyName $companyName `
-product $product `
-Verbose `
-Name "shop-website-app-sql-storage-pe-deployment"
