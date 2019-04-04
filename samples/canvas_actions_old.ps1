#$MODULE_NAME = 'selenium_utils.psd1'
#Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME)

#$driver = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port


<#
pushd C:\tools
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>

#. .\hello.ps1
#[System.Reflection.Assembly]::LoadFrom("F:\Data\App\Selenium Server\WebDriver.dll")
#[System.Reflection.Assembly]::LoadFrom("F:\Data\App\Selenium Server\WebDriver.Support.dll")

$env:SHARED_ASSEMBLIES_PATH = "F:\Data\App\Selenium Server"
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

function Start-SeFirefox2 {

  $shared_assemblies = @(
      'WebDriver.dll',
      'WebDriver.Support.dll'
      )


      #$Driver = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
      #$Driver.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(20)
      return New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
}


$driver = Start-SeFirefox2
#$driver = Start-Sel

$base_url = "http://www.google.com"

$driver.Navigate().GoToUrl($base_url)

# # https://groups.google.com/forum/?fromgroups#!topic/selenium-users/V1eoFUMEPqI
# [OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# # NOTE: failed in phantomjs
# [OpenQA.Selenium.IWebElement]$canvas = $selenium.FindElement([OpenQA.Selenium.By]::Id("tutorial"))
# [void]$builder.Build()
# [void]$builder.MoveToElement($canvas,100,100)
# Start-Sleep -Seconds 4
# [void]$builder.clickAndHold()
# [void]$builder.moveByOffset(40,60)
# Start-Sleep -Seconds 4

# [void]$builder.release()
# [void]$builder.Perform()

# Start-Sleep -Seconds 4

# # Cleanup
# cleanup ([ref]$selenium)

