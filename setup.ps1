#If not run as Administrator, restart powershell process as Administrator
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
  Write-Host "Script must be run as Administrator."
  Break
}

$tempdir = Get-Location
$tempdir = $tempdir.tostring()
$msiArgs = "-qb"

function Install-MSI
{
  [CmdletBinding()]
    Param(
      [parameter(mandatory=$true,ValueFromPipeline=$true,ValueFromPipelinebyPropertyName=$true)]
      [ValidateNotNullorEmpty()]
      [string]$msi,
      [parameter()]
      [ValidateNotNullorEmpty()]
      [string]$targetDir
    )
  if (!(Test-Path $msi))
  {
    throw "Path to the MSI File $($msi) is invalid. Please supply a valid MSI file"
  }
  $arguments = @(
    "/qn"
    "/norestart"
    "/i"
    "`"$msi`""
  )
  if ($targetDir)
  {
    if (!(Test-Path $targetDir))
	{
        throw "Path to the Installation Directory $($targetDir) is invalid. Please supply a valid installation directory"
    }
    $arguments += "INSTALLDIR=`"$targetDir`""
  }
  Write-Host "Installing $msi ..."
  $process = Start-Process -FilePath msiexec.exe -ArgumentList $arguments -Wait -PassThru
  if ($Number -eq 0)
  {
    Write-Host "Install successful."
  }
  ElseIf ($process.ExitCode -eq 3010)
  {
    Write-Host "Install successful. REBOOT REQUIRED."
  }
  else
  {
    Write-ERROR "Install exited with code $($process.ExitCode)."
  }
}

function Get-InstalledApps
{
    if ([IntPtr]::Size -eq 4) {
        $regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    }
    else {
        $regpath = @(
            'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
            'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
        )
    }
    Get-ItemProperty $regpath | .{process{if($_.DisplayName -and $_.UninstallString) { $_ } }} | Select DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString |Sort DisplayName
}


#$appToMatch = 'Vagrant'
#$msiFile = $tempdir+"\vagrant_1.9.3.msi"
$appToMatch = '*Puppet Agent*'
$msiFile = $tempdir+"\puppet-agent-x64-latest.msi"
$msiUrl = "https://downloads.puppetlabs.com/windows/puppet-agent-x64-latest.msi"

wget -UseBasicParsing $msiUrl -OutFile $msiFile
$result = Get-InstalledApps | where {$_.DisplayName -like $appToMatch}
If ($result -eq $null)
{
  "$msiFile" | Install-MSI
}
