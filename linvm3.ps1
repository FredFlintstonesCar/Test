Remove-AzResourceGroup -Name "RG3" -Force -AsJob

# Variables
$ResourceGroupName = "RG4"
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

# Get the public IP address of the VM
$publicIpAddress = az vm show --resource-group $resourceGroupName --name $vmName --show-details --query "publicIps" --output tsv
echo "Public IP Address:" 
echo $publicIpAddress

# Generate SSH key pair
ssh-keygen -t rsa -b 2048 -f ~/.ssh/azure_ssh_key -N "" -q

# Upload SSH public key to the VM
az vm user update --resource-group $ResourceGroupName --name $vmName --username $adminUsername --ssh-key-value "$(cat ~/.ssh/azure_ssh_key.pub)"

# Display SSH private key
cat ~/.ssh/azure_ssh_key

# Install Nmap
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "apt-get update && apt-get install -y nmap"

# Install xRDP
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo apt-get install -y xrdp"
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo systemctl enable xrdp"
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "echo xfce4-session >~/.xsession"
az vm run-command invoke --resource-group $ResourceGroupName --name $vmName --command-id RunShellScript --script "sudo service xrdp restart"
