$VHDpath = "c:\Hyper-V\UnifiController.vhdx"
$ISO = "c:\admin\ISO\ubuntu-16.04.1-server-amd64.iso"
$ISOPath = "c:\admin\ISO\"
$VMName = "UnifiController"
$ServerName = "Clark-PC"
$VMSwitch = "External vSwitch"

If (!(Test-Path $ISOpath)) 
{
New-Item -Path $ISOpath -ItemType Directory
}
Invoke-WebRequest "http://releases.ubuntu.com/16.04.1/ubuntu-16.04.1-server-amd64.iso" -UseBasicParsing -OutFile "$ISO"
New-VHD -Path $VHDpath -SizeBytes 10GB -Fixed
New-VM -Name $VMName -MemoryStartupBytes 1024MB -Generation 1
Add-VMHardDiskDrive -VMName $VMName -Path $VHDpath
Set-VMDvdDrive -VMName $VMName -ControllerNumber 1 -Path $ISO
Get-VMNetworkAdapter -VMName $VMName | Connect-VMNetworkAdapter -SwitchName $VMSwitch
Start-VM -Name UnifiController
vmconnect $ServerName $VMName
