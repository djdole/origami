Add-Type -AssemblyName System.IO.Compression.FileSystem
function unzip
{
    param([string]$zipfile, [string]$outpath)

    [System.IO.Compression.ZipFile]::ExtractToDirectory($zipfile, $outpath)
}

function RmIfExists
{
  [CmdletBinding()]
    Param(
      [parameter(mandatory=$true)]
      [ValidateNotNullorEmpty()]
      [string]$path
    )
	if([System.IO.File]::Exists($path))
	{
	  #rm "$path"
	  Remove-Item -Path "$path" -Force
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
  if ($process.ExitCode -eq 0)
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
    Download -url "$url" -saveto "$path"
    "$path" | Install-MSI
  }
}