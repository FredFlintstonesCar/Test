Remove-AzResourceGroup -Name "RG7" -Force -AsJob

# Variables
$ResourceGroupName = "RG8"
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

# Open ports for Nmap and xRDP
az vm open-port --resource-group $resourceGroupName --name $vmName --port 3389 --priority 1001 --no-wait
az vm open-port --resource-group $resourceGroupName --name $vmName --port 22 --priority 1002 --no-wait

# Get the public IP address and store it in a variable
$publicIpAddress = az vm show --resource-group $resourceGroupName --name $vmName --query "publicIps" --output tsv
echo "Public IP Address: $publicIpAddress"

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/azure_ssh_key -N ""

# Upload SSH public key to the VM
az vm user update --resource-group $resourceGroupName --name $vmName --username $adminUsername --ssh-key-value "$(cat ~/.ssh/azure_ssh_key.pub)"

# Display SSH private key
cat ~/.ssh/azure_ssh_key

# Wait for VM provisioning to complete
az vm wait --name $vmName --resource-group $ResourceGroupName --created

# Install Nmap
az vm extension set `
    --resource-group $resourceGroupName `
    --vm-name $vmName `
    --name customScript `
    --publisher Microsoft.Azure.Extensions `
    --version 2.1 `
    --settings '{"script": "apt update && apt install -y nmap"}'

# Install xRDP
az vm extension set `
    --resource-group $resourceGroupName `
    --vm-name $vmName `
    --name customScript `
    --publisher Microsoft.Azure.Extensions `
    --version 2.1 `
    --settings '{"script": "sudo apt install -y xrdp"}'

echo "running commands"
# SSH into the VM and install software (example: installing Apache web server)
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo systemctl enable xrdp"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\necho xfce4-session >~/.xsession"}'
az vm extension set --resource-group $resourceGroupName --vm-name $vmName --name customScript --publisher Microsoft.Azure.Extensions --settings '{"script":"#!/bin/bash\nsudo service xrdp restart"}'
