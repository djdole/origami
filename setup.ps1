#If not run as Administrator, restart powershell process as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Host "Script must be run as Administrator."
  Break
}

$curdir = split-path -parent $MyInvocation.MyCommand.Definition
$tempdir = $env:TEMP
. "scripts\functions.ps1"

# Install puppet
GetAndInstall-MSI -name "*Puppet Agent*" -path "$tempdir\puppet-agent-x64-latest.msi" -url "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"

#Install chrome, virtualbox, & vagrant
puppet module install edestecd-software --version 1.1.0
puppet apply "scripts\chrome.pp"
puppet apply "scripts\virtualbox.pp"
puppet apply "scripts\vagrant.pp"

# Get packer
#https://releases.hashicorp.com/packer/1.0.0/
$VMDir = $curdir + "\vm"
$PackerZip = $VMDir + "\packer.zip"
$PackerExe = $VMDir + "\packer.exe"
if(![System.IO.File]::Exists($PackerExe) -And ![System.IO.File]::Exists($PackerZip))
{
  Download -url "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_windows_amd64.zip" -saveto "$PackerZip"
}
if(![System.IO.File]::Exists($PackerExe))
{
  unzip "$PackerZip" "$VMDir"
}
RmIfExists -path "$PackerZip"

# Build Packer box.
$name = "BLANK"
$BoxFile = $VMDir + "\" + $name + ".box"
$BoxFileFullPath = $VMDir + "\" + $BoxFile
$BoxJson = $VMDir + "\" + $name + ".json"
RmIfExists -path "$BoxFileFullPath"

pushd "$VMDir"
./packer.exe build -only virtualbox-iso "$BoxJson"
popd
if([System.IO.File]::Exists($BoxFileFullPath))
{
  vagrant box remove "$name"
  vagrant box add "$name" "$BoxFile"
}
RmIfExists -path "$BoxFileFullPath"