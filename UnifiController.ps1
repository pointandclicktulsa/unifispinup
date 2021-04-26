# Begin log file, this will be placed on the client the script is being run from, do not modify unless you want to disable logging
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\admin\Unifi_log.txt -append

# Script variables, change as needed
# If you want to run this against a remote Hyper-V host, change $ServerName to a proper computer name.
# If you have multiple External vSwitches you'll probably also have to manually input the name of the desired vSwitch in $VMSwitch
$ISO = "c:\admin\iso\ubuntu-20.04.2-live-server-amd64.iso"
$ISOPath = "c:\admin\iso\"
$URL = "https://releases.ubuntu.com/20.04.2/ubuntu-20.04.2-live-server-amd64.iso"
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
echo "Downloading Ubuntu Server 20.04.X LTS ISO"
$WebClient.DownloadFile($url, $ISO)
Write-Output "Time Taken: $((Get-Date).Subtract($start_time).seconds) second(s)"
}
else {
echo "Ubuntu Server 20.04.X LTS ISO already exists!"
}

# Create VHDX, VM, attach vSwitch, mount Ubuntu ISO
New-VHD -Path $VHDpath -SizeBytes 40GB
New-VM -Name $VMName -MemoryStartupBytes 2048MB -Generation 2
Set-VMMemory -VMName $VMName -DynamicMemoryEnabled 0
Add-VMHardDiskDrive -VMName $VMName -Path $VHDpath
Add-VMDvdDrive -VMName $VMName -Path $ISO
if ($VMSwitch -ne $null) {
  Get-VMNetworkAdapter -VMName $VMName |
    Connect-VMNetworkAdapter -SwitchName $VMSwitch
}
$dvd = Get-VMDvdDrive -VMName $VMName
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off -FirstBootDevice $dvd
Set-VM -Name $VMName -ProcessorCount 2 -CheckpointType Production -AutomaticStartAction Start -AutomaticCheckpointsEnabled 0 -AutomaticStopAction ShutDown
Enable-VMIntegrationService -Name "Guest Service Interface" -VMName $VMName

# Start and connect to VM
Start-VM -Name $VMName
vmconnect $ServerName $VMName

# End log file
Stop-Transcript
