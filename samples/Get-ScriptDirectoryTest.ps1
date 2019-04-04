#Directory test
$DebugPreference = 'Continue'
write-host "PSScriptRoot =" $PSScriptRoot
write-host "MyInvocation =" $MyInvocation
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
write-host "here =" $here
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path)
write-host "sut =" $sut

$script_directory = Get-ScriptDirectory
write-host "script_directory =" $script_directory

function Get-ScriptDirectory
{
  [string]$scriptDirectory = $null

  #if ($host.Version.Major -gt 2) {
  if ($PSVersionTable.PSVersion.Major -gt 3) {
    $scriptDirectory = (Get-Variable PSScriptRoot).Value
    Write-Debug ('$PSScriptRoot: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.PSCommandPath)
    Write-Debug ('$MyInvocation.PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }

    $scriptDirectory = Split-Path -Parent $PSCommandPath
    Write-Debug ('$PSCommandPath: {0}' -f $scriptDirectory)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
  } else {
    $scriptDirectory = [System.IO.Path]::GetDirectoryName($MyInvocation.MyCommand.Definition)
    if ($scriptDirectory -ne $null) {
      return $scriptDirectory;
    }
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSScriptRoot) {
      $scriptDirectory = $Invocation.PSScriptRoot
    } elseif ($Invocation.MyCommand.Path) {
      $scriptDirectory = Split-Path $Invocation.MyCommand.Path
    } else {
      $scriptDirectory = $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf('\'))
    }
    return $scriptDirectory
  }
}