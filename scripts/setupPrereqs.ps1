#If not run as Administrator, restart powershell process as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Host "Script must be run as Administrator."
  Break
}

$tempdir = $env:TEMP
. "scripts\functions.ps1"

# Install Virtualbox
$version = "5.1.22"
$bld = "115126"
$url = "http://download.virtualbox.org/virtualbox/$version/VirtualBox-$version-$bld-Win.exe"
GetAndInstall-EXE -name "*VirtualBox*" -path "virtualbox.exe" -url "$url"

# Install puppet
$file = "puppet-agent-x64-latest.msi"
$url = "https://downloads.puppetlabs.com/windows/$file"
#GetAndInstall-MSI -name "*Puppet Agent*" -path "$tempdir\$file" -url "$url"

# Install Vagrant
$version = "1.9.2"
$url = "https://releases.hashicorp.com/vagrant/$version/vagrant_$version.msi"
GetAndInstall-MSI -name "*Vagrant*" -path "$tempdir\vagrant_$version.msi" -url "$url"
