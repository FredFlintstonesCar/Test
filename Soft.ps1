$vm = Get-AzVM -ResourceGroupName $resourceGroupName -Name $vmName

# Enable PowerShell remoting on the VM
Enable-AzVMPSRemoting -ResourceGroupName $resourceGroupName -Name $vmName -Force

# Establish a remote session
$session = New-PSSession -ComputerName $vm.Name -Credential $vm.Credentials

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
