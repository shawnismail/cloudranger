# Add-AzureRmAccount

$rgName="rangervnetrg"
$location="eastus2"

# Create a resource group.
New-AzureRmResourceGroup -Name $rgName -Location $location

# Subnet configuration
$subnet1config = New-AzureRmVirtualNetworkSubnetConfig -Name "mysubnet1" -AddressPrefix "10.3.1.0/24"
$subnet2config = New-AzureRmVirtualNetworkSubnetConfig -Name "mysubnet2" -AddressPrefix "10.3.2.0/24"


# Create the VNet with the subnet configurations
$vnet = New-AzureRmVirtualNetwork -ResourceGroupName $rgName -Name "myvnet" -AddressPrefix '10.3.0.0/16' -Location $location -Subnet $subnet1config, $subnet2config


# Create Public IP addresses for the virtual machines
$server1pubip = New-AzureRmPublicIpAddress -ResourceGroupName $rgName -Name "server1-pubip" -location $location -AllocationMethod Dynamic 
$server2pubip = New-AzureRmPublicIpAddress -ResourceGroupName $rgName -Name "server2-pubip" -location $location -AllocationMethod Dynamic
$server3pubip = New-AzureRmPublicIpAddress -ResourceGroupName $rgName -Name "server3-pubip" -location $location -AllocationMethod Dynamic

# Create NICs for the virtual machines
$server1nic = New-AzureRmNetworkInterface -ResourceGroupName $rgName -Location $location -Name "server1-nic"  -Subnet $vnet.Subnets[0] -PublicIpAddress $server1pubip -PrivateIpAddress "10.3.1.5"
$server2nic = New-AzureRmNetworkInterface -ResourceGroupName $rgName -Location $location -Name "server2-nic"  -Subnet $vnet.Subnets[0] -PublicIpAddress $server2pubip -PrivateIpAddress "10.3.1.6"
$server3nic = New-AzureRmNetworkInterface -ResourceGroupName $rgName -Location $location -Name "server3-nic"  -Subnet $vnet.Subnets[1] -PublicIpAddress $server3pubip -PrivateIpAddress "10.3.2.5"


############################################################################


# Acquire Server credentials
$servercred = Get-Credential -Message "Enter a username and password for the servers"

# Create Server 1, 2 & 3
$server1vmConfig = New-AzureRmVMConfig -VMName "server1" -VMSize "Standard_DS2" | `
  Set-AzureRmVMOperatingSystem -Windows -ComputerName "server1" -Credential $servercred | `
  Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version latest | `
  Set-AzureRmVMBootDiagnostics -Disable | Add-AzureRmVMNetworkInterface -Id $server1nic.Id 

$server2vmConfig = New-AzureRmVMConfig -VMName "server2" -VMSize "Standard_DS2" | `
  Set-AzureRmVMOperatingSystem -Windows -ComputerName "server2" -Credential $servercred | `
  Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version latest | `
  Set-AzureRmVMBootDiagnostics -Disable | Add-AzureRmVMNetworkInterface -Id $server2nic.Id 

$server3vmConfig = New-AzureRmVMConfig -VMName "server3" -VMSize "Standard_DS2" | `
  Set-AzureRmVMOperatingSystem -Windows -ComputerName "server3" -Credential $servercred | `
  Set-AzureRmVMSourceImage -PublisherName "MicrosoftWindowsServer" -Offer "WindowsServer" -Skus "2016-Datacenter" -Version latest | `
  Set-AzureRmVMBootDiagnostics -Disable | Add-AzureRmVMNetworkInterface -Id $server3nic.Id 



$server1vm = New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $server1vmConfig 
$server2vm = New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $server2vmConfig
$server3vm = New-AzureRmVM -ResourceGroupName $rgName -Location $location -VM $server3vmConfig


# Remove Resource Group
# Remove-AzureRmResourceGroup -Name $rgName


#############################################################
# Some helpful cmdlets 

## Get all resopurce groups in the Subscription
# Get-AzureRmResourceGroup

## Get Azure VNet information
# Get-AzureRmVirtualNetwork -ResourceGroupName rangervnetrg -Name myvnet

## Get all Azure Public IP Addresses
# Get-AzureRmPublicIpAddress

## Get all Azure Network Interfaces 
# Get-AzureRmNetworkInterface