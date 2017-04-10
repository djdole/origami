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
puppet apply scripts/chrome.pp
puppet apply scripts/virtualbox.pp
puppet apply scripts/vagrant.pp

# Get packer
#https://releases.hashicorp.com/packer/1.0.0/
$ZipFile = $curdir + "\packer.zip"
Download -url "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_windows_amd64.zip" -saveto "$ZipFile"
unzip "$ZipFile" "$curdir"
rm "packer.zip"

# Build Packer box.
$name = "BLANK"
$BoxFile = "vm\" + $name + ".box"
$BoxFileFullPath = $curdir + "\" + $BoxFile
$BoxJson = $name + ".json"
rm "$BoxFile"
pushd vm
packer build -only virtualbox-iso "$BoxJson"
popd
vagrant box remove "$name"
vagrant box add "$name" "$BoxFile"
rm "$BoxFile"