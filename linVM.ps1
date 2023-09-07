# Variables
$resourceGroupName = "myres3"
$location = "East US"  # You can change the location as per your preference
$vmName = "mylinuxvm"
$adminUsername = "azureuser"  # Change this to your desired username
$adminPassword = "P@ssw0rd123!"  # Change this to your desired password

# Create a resource group
az group create --name $resourceGroupName --location $location

# Create a Linux virtual machine
az vm create `
    --resource-group $resourceGroupName `
    --name $vmName `
    --image "Ubuntu2204" `
    --admin-username $adminUsername `
    --admin-password $adminPassword `
    --size Standard_B2s  # You can change the VM size as needed

$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Enable PowerShell remoting on the VM
Enable-AzVMPSRemoting -ResourceGroupName $resourceGroupName -Name $vmName

# Establish a remote session
$session = New-PSSession -HostName $vm.Name -UserName $adminUsername -Password (ConvertTo-SecureString $adminPassword -AsPlainText -Force)

# Install nmap and xrdp
Invoke-Command -Session $session -ScriptBlock {
    sudo apt update
    sudo apt install nmap xrdp -y
    sudo systemctl enable xrdp
    echo xfce4-session >~/.xsession
    sudo service xrdp restart
}

# Close the remote session
Remove-PSSession $session
