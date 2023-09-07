# Variables
$ResourceGroupName = "RG1"
$location = "East US"  # Change to your desired location
$vmName = "LinuxVM"
$adminUsername = "azureuser"  # Change this to your desired username
$adminPassword = "P@ssw0rd123!"  # Change this to your desired password

# Create a resource group
az group create --name $ResourceGroupName --location $location

# Create a Linux virtual machine
az vm create `
    --resource-group $ResourceGroupName `
    --name $vmName `
    --image "Ubuntu2204" `
    --admin-username $adminUsername `
    --admin-password $adminPassword `
    --size Standard_B2s  # You can change the VM size as needed

# Open port 22 for SSH (Linux VM)
az vm open-port --resource-group $resourceGroupName --name $vmName --port 22

# Wait for VM provisioning to complete
az vm wait --name $vmName --resource-group $ResourceGroupName --created

# Get the public IP address of the VM
publicIp=$(az vm show --resource-group $resourceGroupName --name $vmName --query "publicIps" --output tsv)

# Wait for a few seconds to ensure remoting is enabled
# Start-Sleep -Seconds 30
# Establish a remote session
# $session = New-PSSession -ComputerName $vm.Name -Credential $adminCredential

# SSH into the VM and install software (example: installing Apache web server)
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo apt update && sudo apt install -y nmap xrdp"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo systemctl enable xrdp"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\necho xfce4-session >~/.xsession"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo service xrdp restart"}'
