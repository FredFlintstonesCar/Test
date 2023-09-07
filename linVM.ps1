# Variables
$resourceGroupName = "myres"
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
    --image UbuntuLTS `
    --admin-username $adminUsername `
    --admin-password $adminPassword `
    --size Standard_DS2_v2  # You can change the VM size as needed
