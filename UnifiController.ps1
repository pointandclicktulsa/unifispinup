﻿# Begin log file, this will be placed on the client the script is being run from, do not modify unless you want to disable logging
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Unifi.txt -append

# Script variables, change as needed
# If you want to run this against a remote Hyper-V host, change $ServerName to a proper computer name.
# If you have multiple External vSwitches you'll probably also have to manually input the name of the desired vSwitch in $VMSwitch
$ISO = "c:\admin\iso\ubuntu-18.04-server-amd64.iso"
$ISOPath = "c:\admin\iso\"
$URL = "http://cdimage.ubuntu.com/releases/18.04/release/ubuntu-18.04-server-amd64.iso"
$start_time = Get-Date
$WebClient = New-Object System.Net.WebClient
$VMName = "Unifi"
$VHDpath = "c:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"
$ServerName = "$env:computername"
$VMSwitch = Get-VMSwitch -SwitchType External |
              Select-Object -First 1 |
              ForEach-Object Name

# Test for ISO folder existence
If (!(Test-Path $ISOpath) -And !(Test-Path "C:\admin\isos\")) {
New-Item -Path $ISOpath -ItemType Directory
}
else {
echo "ISO directory already exists!"
}

# Download Ubuntu ISO
If (!(Test-Path $ISO)) {
echo "Downloading Ubuntu Server 18.04 LTS ISO"
$WebClient.DownloadFile($url, $ISO)
Write-Output "Time Taken: $((Get-Date).Subtract($start_time).seconds) second(s)"
}
else {
echo "Ubuntu Server 18.04 LTS ISO already exists!"
}

# Create VHDX, VM, attach vSwitch, mount Ubuntu ISO
New-VHD -Path $VHDpath -SizeBytes 20GB -Fixed
New-VM -Name $VMName -MemoryStartupBytes 512MB -Generation 1
Add-VMHardDiskDrive -VMName $VMName -Path $VHDpath
Set-VMDvdDrive -VMName $VMName -ControllerNumber 1 -Path $ISO
if ($VMSwitch -ne $null) {
  Get-VMNetworkAdapter -VMName $VMName |
    Connect-VMNetworkAdapter -SwitchName $VMSwitch
}

# Start and connect to VM
Start-VM -Name $VMName
vmconnect $ServerName $VMName

# End log file
Stop-Transcript
