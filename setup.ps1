#If not run as Administrator, restart powershell process as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Host "Script must be run as Administrator."
  Break
}

$curdir = split-path -parent $MyInvocation.MyCommand.Definition
$tempdir = $env:TEMP
. "scripts\functions.ps1"

$Name = "BLANK"
$FileName = $Name + ".box"
$RemoteBoxLoc = "\\morgan\DocuSign\Development\Connect"
$RemoteFileName = $RemoteBoxLoc + "\" + $FileName

$VMDir = $curdir + "\vm"
$BoxFile = $VMDir + "\" + $FileName
$BoxJson = $VMDir + "\" + $Name + ".json"

# Install puppet
GetAndInstall-MSI -name "*Puppet Agent*" -path "$tempdir\puppet-agent-x64-latest.msi" -url "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"

#Install virtualbox, & vagrant
puppet module install edestecd-software --version 1.1.0
#puppet apply "scripts\chrome.pp"
puppet apply "scripts\virtualbox.pp"
puppet apply "scripts\vagrant.pp"

# Check if an existing BOX file exists, if not create it.
if(-Not (Test-Path "$RemoteFileName"))
{
  Write-Host "Notice: Existing '$FileName' VM image not found at '$RemoteBoxLoc'."
  Write-Host "Notice: Preparing to create '$FileName'..."

  # Bootstrap Packer
  BootstrapPacker -VMDir "$VMDir" -PackerUrl "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_windows_amd64.zip"

  # Build Packer box.
  Remove -Path "$BoxFile"

  pushd "$VMDir"
    Write-Host "Notice: Creating '$FileName'..."
    ./packer.exe build -only virtualbox-iso "$BoxJson"
  popd
  
  if (-Not (Test-Path $targetDir))
  {
    New-Item -ItemType directory -Path "$RemoteBoxLoc" -Force
  }
  if (-Not (Test-Path $RemoteFileName))
  {
    Write-Host "Notice: Copying '$FileName' to '$RemoteBoxLoc'..."
    Copy-Item -Path "$BoxFile" -Destination "$RemoteBoxLoc" -Force
  }
}

if([System.IO.File]::Exists($BoxFile))
{
  vagrant box remove "$Name"
  vagrant box add "$Name" "$BoxFile"
}
Remove -Path "$BoxFile"
