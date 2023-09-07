# Variables
$ResourceGroupName = "myres5"
$location = "East US"  # You can change the location as per your preference
$vmName = "mylinuxvm"
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

# Wait for a few seconds to ensure remoting is enabled
Start-Sleep -Seconds 30

# Get the Azure VM
$vm = Get-AzVM -ResourceGroupName $ResourceGroupName -Name $vmName

# Convert the admin password to a SecureString
$adminSecurePassword = ConvertTo-SecureString -String $adminPassword -AsPlainText -Force

# Create a PSCredential object
$adminCredential = New-Object System.Management.Automation.PSCredential ($adminUsername, $adminSecurePassword)

# Enable PowerShell remoting on the VM
Enable-AzVMPSRemoting -ResourceGroupName $ResourceGroupName -Name $vmName

# Wait for a few seconds to ensure remoting is enabled
Start-Sleep -Seconds 30

# Establish a remote session
$session = New-PSSession -ComputerName $vm.Name -Credential $adminCredential

# Wait for a few seconds to ensure remoting is enabled
Start-Sleep -Seconds 30

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
