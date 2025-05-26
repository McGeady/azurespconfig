Connect-AzAccount -ServicePrincipal `
-TenantId 634a6451-0a9a-41e3-b71b-d8752ce3166f `
-Credential (New-Object -TypeName System.Management.Automation.PSCredential `
-ArgumentList 913f6b02-47c7-4de2-91ab-43efac94c4cf, (ConvertTo-SecureString Sa58Q~215ABm8SS4YySvyuWgP4CGOVhnVfDsmbwg  -AsPlainText -Force))

$resourceGroup = "rg_devDeployment"
$location = "West Europe"
$vmName = "DevelopmentVM"
$adminUsername = "devadmin"
$adminPassword = ConvertTo-SecureString "D@h(sY7pB/J`yNygAP,6ZF.&VlLhnEb" -AsPlainText -Force
$cred = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminPassword)
$size = "Standard_DS1_v2"
$image = "Win2022Datacenter"
$openPorts = 3389

New-AzResourceGroup -Name $resourceGroup -Location $location
$vnet = New-AzVirtualNetwork -ResourceGroupName $resourceGroup -Location $location `
  -Name "dev_vNet" -AddressPrefix "10.0.0.0/16"

$subnet = Add-AzVirtualNetworkSubnetConfig -Name "devSubnet" -AddressPrefix "10.0.0.0/24" -VirtualNetwork $vnet
Set-AzVirtualNetwork -VirtualNetwork $vnet

$publicIp = New-AzPublicIpAddress -ResourceGroupName $resourceGroup -Location $location `
  -Name "devVMpublicIP" -AllocationMethod Static

$nic = New-AzNetworkInterface -ResourceGroupName $resourceGroup -Location $location `
  -Name "devVMnic" -SubnetId $vnet.Subnets[0].Id -PublicIpAddressId $publicIp.Id -NetworkSecurityGroupId $nsg.Id

$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $size | `
    Set-AzVMOperatingSystem -Windows -ComputerName $vmName -Credential $cred | `
    Set-AzVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus $image -Version "latest" | `
    Add-AzVMNetworkInterface -Id $nic.Id | `
    Set-AzVMBootDiagnostic -Enable -ResourceGroupName $resourceGroup

New-AzVM -ResourceGroupName $resourceGroup -Location $location -VM $vmConfig
