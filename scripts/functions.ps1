Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function Remove
{
  [CmdletBinding()]
  Param(
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$Path
  )
  if([System.IO.File]::Exists($Path))
  {
    #rm "$Path"
    Remove-Item -Path "$Path" -Force
  }
}

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
  if (-Not (Test-Path $msi))
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
    if (-Not (Test-Path $targetDir))
	{
        throw "Path to the Installation Directory $($targetDir) is invalid. Please supply a valid installation directory"
    }
    $arguments += "INSTALLDIR=`"$targetDir`""
  }
  Write-Host "Notice: Installing '$msi'..."
  $process = Start-Process -FilePath msiexec.exe -ArgumentList $arguments -Wait -PassThru
  if ($process.ExitCode -eq 0)
  {
    Write-Host "Notice: Install successful."
  }
  ElseIf ($process.ExitCode -eq 3010)
  {
    Write-Host "Notice: Install successful. REBOOT REQUIRED."
  }
  else
  {
    Write-ERROR "Notice: Install exited with code $($process.ExitCode)."
  }
}

function Get-InstalledApps
{
  if ([IntPtr]::Size -eq 4)
  {
    $regpath = 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
  }
  else
  {
    $regpath = @(
      'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
      'HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )
  }
  Get-ItemProperty $regpath | .{process{if($_.DisplayName -and $_.UninstallString) { $_ } }} | Select DisplayName, Publisher, InstallDate, DisplayVersion, UninstallString |Sort DisplayName
}

function Download
{
  [CmdletBinding()]
  Param(
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$url,
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$saveto
  )
  $AllProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
  [System.Net.ServicePointManager]::SecurityProtocol = $AllProtocols
  wget -UseBasicParsing "$url" -OutFile "$saveto"
}

function GetAndInstall-MSI
{
  [CmdletBinding()]
  Param(
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$name,
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$path,
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$url
  )
  $result = Get-InstalledApps | where {$_.DisplayName -like $name}
  if ($result -eq $null)
  {
	Write-Host "Notice: Downloading msi from '$url'..."
    Download -url "$url" -saveto "$path"
    "$path" | Install-MSI
  }
}

function BootstrapPacker
{
  [CmdletBinding()]
  Param(
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$VMDir,
    [parameter(mandatory=$true)]
    [ValidateNotNullorEmpty()]
    [string]$PackerUrl
  )
  
  # Get packer from:
  # https://releases.hashicorp.com/packer/1.0.0/
  $PackerZip = $VMDir + "\packer.zip"
  $PackerExe = $VMDir + "\packer.exe"
  if(![System.IO.File]::Exists($PackerExe))
  {
    if(![System.IO.File]::Exists($PackerZip))
    {
	  Write-Host "Downloading zipped packer from '$PackerUrl'..."
      Download -url "$PackerUrl" -saveto "$PackerZip"
    }
    unzip "$PackerZip" "$VMDir"
  }
  Remove -Path "$PackerZip"
}