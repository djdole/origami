#If not run as Administrator, restart powershell process as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Host "Script must be run as Administrator."
  Break
}

#$tempdir = Get-Location.tostring()
$tempdir = $env:TEMP
. "scripts\functions.ps1"

GetAndInstall-MSI -name "*Puppet Agent*" -path "$tempdir\puppet-agent-x64-latest.msi" -url "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"

puppet module install edestecd-software --version 1.1.0
puppet apply scripts/chrome.pp
puppet apply scripts/virtualbox.pp
puppet apply scripts/vagrant.pp
