Remove-AzResourceGroup -Name "RG6" -Force -AsJob
Remove-AzResourceGroup -Name "RG8" -Force -AsJob

# Variables
$ResourceGroupName = "RG9"
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
    --public-ip-sku Standard `
    --admin-username $adminUsername `
    --admin-password $adminPassword `
    --size Standard_B2s

# Wait for VM provisioning to complete
az vm wait --name $vmName --resource-group $ResourceGroupName --created

# Open ports for Nmap and xRDP
az vm open-port --resource-group $resourceGroupName --name $vmName --port 3389 --priority 1001
az vm open-port --resource-group $resourceGroupName --name $vmName --port 22 --priority 1002

# Get the public IP address and store it in a variable
$publicIpAddress = az vm show --resource-group $ResourceGroupName --name $vmName --query "publicIpAddress" --output tsv
echo "Public IP Address:" 
echo $publicIpAddress

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/azure_ssh_key -N ""

# Upload SSH public key to the VM
az vm user update --resource-group $resourceGroupName --name $vmName --username $adminUsername --ssh-key-value "$(cat ~/.ssh/azure_ssh_key.pub)"

# Display SSH private key
cat ~/.ssh/azure_ssh_key

# Base64 encode the script for Nmap installation
$nmapScriptBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("apt-get update && apt-get install -y nmap"))

# Base64 encode the script for xRDP installation
$xrdpScriptBase64 = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("sudo apt-get install -y xrdp"))

# Install Nmap
az vm extension set `
    --resource-group $resourceGroupName `
    --vm-name $vmName `
    --name customScript `
    --publisher Microsoft.Azure.Extensions `
    --version 2.1 `
    --settings "{\"script\": \"$nmapScriptBase64\"}"

# Install xRDP
az vm extension set `
    --resource-group $resourceGroupName `
    --vm-name $vmName `
    --name customScript `
    --publisher Microsoft.Azure.Extensions `
    --version 2.1 `
    --settings "{\"script\": \"$xrdpScriptBase64\"}"
    
echo "running commands"
pause

# SSH into the VM and install software (example: installing Apache web server)
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo systemctl enable xrdp"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\necho xfce4-session >~/.xsession"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo service xrdp restart"}'
