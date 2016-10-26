﻿# Begin log file, this will be placed on the client the script is being run from, do not modify unless you want to disable logging
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Unifi.txt -append

# Script variables, change as needed
$ISO = "c:\admin\ISO\ubuntu-16.04.1-server-amd64.iso"
$ISOPath = "c:\admin\ISO\"
$VMName = "Unifi"
$VHDpath = "c:\Hyper-V\$VMName.vhdx"
$ServerName = "$env:computername"
$VMSwitch = "Get-VMSwitch -SwitchType External"

# Test for ISO folder existence
If (!(Test-Path $ISOpath) -And !(Test-Path "C:\admin\ISOs\"))
{
New-Item -Path $ISOpath -ItemType Directory
}
else 
{
echo "ISO directory already exists!"
}

# Download Ubuntu ISO
If (!(Test-Path $ISO))
{
Invoke-WebRequest "http://releases.ubuntu.com/16.04.1/ubuntu-16.04.1-server-amd64.iso" -UseBasicParsing -OutFile "$ISO"
}
else
{
echo "Ubuntu 16.04.1 ISO already exists!"
}

# Create VHDX, VM, attach vSwitch, mount Ubuntu ISO
New-VHD -Path $VHDpath -SizeBytes 20GB -Fixed
New-VM -Name $VMName -MemoryStartupBytes 512MB -Generation 1
Add-VMHardDiskDrive -VMName $VMName -Path $VHDpath
Set-VMDvdDrive -VMName $VMName -ControllerNumber 1 -Path $ISO
Get-VMNetworkAdapter -VMName $VMName | Connect-VMNetworkAdapter -SwitchName ($VMSwitch)

# Start and connect to VM
Start-VM -Name $VMName
vmconnect $ServerName $VMName

# End log file
Stop-Transcript
