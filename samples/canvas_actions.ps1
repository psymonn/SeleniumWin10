param(
  [string]$browser,
  [string]$hub_host = '127.0.0.1',
  [string]$hub_port = '4444'
)

$MODULE_NAME = 'SeleniumWin10.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME) -force

$selenium = launch_selenium -browser $browser -hub_host $hub_host -hub_port $hub_port

<#
pushd C:\tools
mklink /D phantomjs C:\phantomjs-1.9.7-windows
symbolic link created for phantomjs <<===>> C:\phantomjs-1.9.7-windows
#>
$base_url = "http://google.com"
$selenium.Navigate().GoToUrl($base_url)
# https://groups.google.com/forum/?fromgroups#!topic/selenium-users/V1eoFUMEPqI
[OpenQA.Selenium.Interactions.Actions]$builder = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
# NOTE: failed in phantomjs
[OpenQA.Selenium.IWebElement]$canvas = $selenium.FindElement([OpenQA.Selenium.By]::Id("main"))
[void]$builder.Build()
[void]$builder.MoveToElement($canvas,100,100)
Start-Sleep -Seconds 4
[void]$builder.clickAndHold()
[void]$builder.moveByOffset(40,60)
Start-Sleep -Seconds 4

[void]$builder.release()
[void]$builder.Perform()

Start-Sleep -Seconds 4

# Cleanup
cleanup ([ref]$selenium)

