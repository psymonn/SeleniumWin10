function DLLfile {
    [string]$shared_assemblies_path = 'F:\Data\App\Selenium Server'
    [string[]]$shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll'
      )

  #$env:SHARED_ASSEMBLIES_PATH = $shared_assemblies_path
  #$shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  pushd $shared_assemblies_path
  $shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2){
    Unblock-File -Path $_;
  }
  write-output $_
  Add-Type -Path $_
  }
  popd

}


function DLL2 {

  $shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll'
  )

  $env:SHARED_ASSEMBLIES_PATH = "F:\Data\Git\Selenium\lib40\"
  $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
  pushd $shared_assemblies_path
  $shared_assemblies | ForEach-Object {

   if ($host.Version.Major -gt 2){
     Unblock-File -Path $_;
   }
   write-output $_
   Add-Type -Path $_
   }
  popd



}

function Start-Sel {
        DLL2
        $Driver = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
        $Driver.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(10)
        $Driver

}
function Start-SeFirefox2 {
   # param([Switch]$Profile)

    # if ($Profile) {
    #     #Doesn't work....
    #     $ProfilePath = Join-Path $PSScriptRoot "Assets\ff-profile\rust_mozprofile.YwpEBLY3hCRX"
    #     $firefoxProfile = New-Object OpenQA.Selenium.Firefox.FirefoxProfile -ArgumentList ($ProfilePath)
    #     $firefoxProfile.WriteToDisk()
    #     New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver" -ArgumentList $firefoxProfile
    # }
    # else {
      DLL2
        $Driver = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
        $Driver.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(10)
        $Driver
  #  }

}
