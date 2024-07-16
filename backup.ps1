# Define variables
$vmNames = @("VM1","VM2")  # Replace with the names of your VMs
$backupPath = "C:\VMBackups"  # Replace with your desired backup directory
$vCenterServer = "YOUR IP"  # Replace with your ESXi or vCenter server IP
$username = "ESXI USERNAME"  # Replace with your ESXi or vCenter username
$password = "ESXI PASSWORD"  # Replace with your ESXi or vCenter password

# Connect to the vCenter or ESXi server
Connect-VIServer -Server $vCenterServer -User $username -Password "$password"

# Ensure the backup directory exists
if (-not (Test-Path -Path $backupPath)) {
    New-Item -ItemType Directory -Path $backupPath
}

# Export each VM to OVF format
foreach ($vmName in $vmNames) {
    try {
        $vm = Get-VM -Name $vmName

        if ($null -eq $vm) {
            Write-Host "VM '$vmName' not found."
            continue
        }

        # Check the power state of the VM and power it off if necessary
        if ($vm.PowerState -ne 'PoweredOff') {
            Stop-VM -VM $vm -Confirm:$false
            # Wait for the VM to power off completely
            do {
                Start-Sleep -Seconds 5
                $vm = Get-VM -Name $vmName
            } while ($vm.PowerState -ne 'PoweredOff')
        }

        $exportPath = Join-Path -Path $backupPath -ChildPath $vmName

        # Ensure the export path exists
        if (-not (Test-Path -Path $exportPath)) {
            New-Item -ItemType Directory -Path $exportPath
        }

        # Export the VM to OVF format
        Export-VApp -VM $vm -Destination $exportPath -Format OVA -Force
        Write-Host "Successfully exported $vmName to $exportPath"
    } catch {
        Write-Host "Failed to export $vmName. Error: $_"
    }
}

# Disconnect from the vCenter or ESXi server
Disconnect-VIServer -Server $vCenterServer -Confirm:$false
