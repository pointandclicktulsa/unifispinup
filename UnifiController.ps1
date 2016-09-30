$VHDpath = "c:\Hyper-V\UnifiController.vhdx"
$ISOpath = "c:\admin\ISO\ubuntu-16.04.1-server-amd64.iso"
$VMName = "UnifiController"
$servername = "Clark-PC"
$VMSwitch = "External vSwitch"

Invoke-WebRequest "http://releases.ubuntu.com/16.04.1/ubuntu-16.04.1-server-amd64.iso" -UseBasicParsing -OutFile "$ISOpath"
New-VHD -Path $VHDpath -SizeBytes 10GB -Fixed
New-VM -Name $VMName -MemoryStartupBytes 1024MB -Generation 1
Add-VMHardDiskDrive -VMName $VMName -Path $VHDpath
Set-VMDvdDrive -VMName $VMName -ControllerNumber 1 -Path $ISOpath
Get-VMNetworkAdapter -VMName $VMName | Connect-VMNetworkAdapter -SwitchName $VMSwitch
Start-VM -Name UnifiController
vmconnect $servername $VMName