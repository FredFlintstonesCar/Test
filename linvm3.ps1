Remove-AzResourceGroup -Name "RG8" -Force -AsJob

# Variables
$ResourceGroupName = "ResGroup"
$location = "East US"  # Change to your desired location
$vmName = "Linux_Ubuntu2204_VM"
$adminUsername = "azureuser"  # Change this to your desired username
$adminPassword = "P@ssw0rd123!"  # Change this to your desired password

# Create a resource group
az group create --name $ResourceGroupName --location $location --output none
echo "Created Resource Group: $ResourceGroupName"

# Create a Linux virtual machine
az vm create `
    --resource-group $ResourceGroupName `
    --name $vmName `
    --image "Ubuntu2204" `
    --public-ip-sku Standard `
    --admin-username $adminUsername `
    --admin-password $adminPassword `
    --size Standard_B2s `
    --output none

# Wait for VM provisioning to complete
az vm wait --name $vmName --resource-group $ResourceGroupName --created

# Open ports for Nmap and xRDP
az vm open-port --resource-group $resourceGroupName --name $vmName --port 3389 --priority 1001 --output none
az vm open-port --resource-group $resourceGroupName --name $vmName --port 22 --priority 1002 --output none

# Get the public IP address of the VM
$publicIpAddress = az vm show --resource-group $resourceGroupName --name $vmName --show-details --query "publicIps" --output tsv

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/azure_ssh_key -N ""
echo "Key Generated"

# Upload SSH public key to the VM
az vm user update --resource-group $ResourceGroupName --name $vmName --username $adminUsername --ssh-key-value "$(cat ~/.ssh/azure_ssh_key.pub)" --output none
echo "Key Uploaded"

# Display SSH private key
# cat ~/.ssh/azure_ssh_key

# Update and install desktop
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo apt update -y" --output none
echo "VM updated"
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo apt install kde-plasma-desktop -y" --output none
echo "VM Desktop installed"

# Install Nmap
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo apt install -y nmap" --output none
echo "Nmap installed"

# Install xRDP
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo apt install -y xrdp" --output none
echo "XRDP installed"
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo systemctl enable xrdp" --output none
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "echo xfce4-session >~/.xsession" --output none
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo service xrdp restart" --output none
echo "Ready"
echo "Public IP Address: " $publicIpAddress
