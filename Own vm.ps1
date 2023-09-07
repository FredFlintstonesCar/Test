# Define your Azure resource group and VM details
$resourceGroupName = "myResGrp"
$location = "East US" # Choose an Azure region
$vmName = "YourVMName"
$vmSize = "Standard_B2s" # Choose an appropriate VM size
$adminUsername = "YourAdminUsername"
$adminPassword = "YourAdminPassword" # Replace with your own secure password

# Create a new resource group
New-AzResourceGroup -Name $resourceGroupName -Location $location

# Create a new Ubuntu VM configuration
$vmConfig = New-AzVMConfig -VMName $vmName -VMSize $vmSize
$vmConfig = Set-AzVMOperatingSystem -VM $vmConfig -Linux -ComputerName $vmName -Credential (Get-Credential -UserName $adminUsername -Password $adminPassword)
$vmConfig = Set-AzVMSourceImage -VM $vmConfig -PublisherName Canonical -Offer UbuntuServer -Skus 18.04-LTS -Version latest
$vmConfig = Add-AzVMNetworkInterface -VM $vmConfig -Id (Get-AzNetworkInterface | Where-Object { $_.ResourceGroupName -eq $resourceGroupName }).Id

# Create a new VM in Azure
New-AzVM -ResourceGroupName $resourceGroupName -Location $location -VM $vmConfig

# Optionally, open SSH port (22) in the VM's NSG
$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName
$vm | Get-AzNetworkSecurityGroup | Get-AzNetworkSecurityRuleConfig | Where-Object { $_.Name -eq 'default-allow-ssh' } | Set-AzNetworkSecurityRuleConfig -Access Allow -Direction Inbound

# Update the NSG
$vm | Get-AzNetworkSecurityGroup | Set-AzNetworkSecurityGroup
