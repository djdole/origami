#If not run as Administrator, restart powershell process as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Host "Script must be run as Administrator."
  Break
}

$curdir = split-path -parent $MyInvocation.MyCommand.Definition
$tempdir = $env:TEMP
. "$curdir\scripts\functions.ps1"

$UseSharedBox = $true
$Name = "BLANK"
$FileName = $Name + ".box"
$BoxStore = $curdir + "\STORE"
$BoxStoreFile = $BoxStore + "\" + $FileName

$VMDir = $curdir + "\vm"
$BoxFile = $VMDir + "\" + $FileName
$BoxJson = $VMDir + "\" + $Name + ".json"
#Install Prereqs (if necessary)...
. "$curdir\scripts\setupPrereqs.ps1"
  
# Check if an existing BOX file exists, if not create it.
if(-Not (Test-Path "$BoxStoreFile") -And $UseSharedBox)
{
  Write-Host "Notice: Existing '$FileName' VM image not found at '$BoxStore'."
  Write-Host "Notice: Preparing to create '$FileName'..."

  # Bootstrap Packer
  BootstrapPacker -VMDir "$VMDir" -PackerUrl "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_windows_amd64.zip"

  # Build Packer box.
  Remove -File "$BoxFile"

  pushd "$VMDir"
    Write-Host "Notice: Creating '$FileName'..."
    ./packer.exe build -only virtualbox-iso "$BoxJson"
  popd
  
  if (-Not (Test-Path $BoxStore))
  {
    New-Item -ItemType directory -Path "$BoxStore" -Force
  }
  if (-Not (Test-Path $BoxStoreFile))
  {
    Write-Host "Notice: Copying '$FileName' to '$BoxStore'..."
    robocopy "$VMDir" "$BoxStore" "$FileName" /njh /njs /ndl /nc /ns
    #Copy-Item -Path "$BoxFile" -Destination "$BoxStore" -Force
  }
}

vagrant plugin repair
vagrant destroy default
vagrant box remove "$Name" --force
#if([System.IO.File]::Exists($BoxFile))
if(-Not (Test-Path "$BoxFile" -PathType Leaf))
{
  robocopy "$BoxStore" "$VMDir" "$FileName" /njh /njs /ndl /nc /ns
}
vagrant box add "$Name" "$BoxFile"
Remove -File "$BoxFile"


#Spin up the virtual machine.
vagrant up



#$PackerZip = $VMDir + "\packer.zip"
#$PackerExe = $VMDir + "\packer.exe"
#if(![System.IO.File]::Exists($PackerExe) -And ![System.IO.File]::Exists($PackerZip))
#{
#  Download -url "https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_windows_amd64.zip" -saveto "$PackerZip"
#}
#if(![System.IO.File]::Exists($PackerExe))
#{
#  unzip "$PackerZip" "$VMDir"
#}
#RmIfExists -path "$PackerZip"

# Build Packer box.
#$BoxFile = $VMDir + "\" + $name + ".box"
#$BoxFileFullPath = $VMDir + "\" + $BoxFile
#$BoxJson = $VMDir + "\" + $name + ".json"
#RmIfExists -path "$BoxFileFullPath"

#  pushd "$VMDir"
#    Write-Host "Notice: Creating '$FileName'..."
#    ./packer.exe build -only virtualbox-iso "$BoxJson"
#  popd
#if([System.IO.File]::Exists($BoxFileFullPath))
#{
#  vagrant box remove "$name"
#  vagrant box add "$name" "$BoxFile"
#}
#RmIfExists -path "$BoxFileFullPath"
