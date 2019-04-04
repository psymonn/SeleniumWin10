
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


function Start-SeFirefox2 {

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


        $Driver = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
        $Driver.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(10)
        $Driver
}
