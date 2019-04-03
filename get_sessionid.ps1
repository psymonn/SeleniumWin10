param(
  [string]$browser,
  [switch]$grid
)

$MODULE_NAME = 'SeleniumWin10.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME) -Force

# Convertfrom-JSON applies To: Windows PowerShell 3.0 and above
[NUnit.Framework.Assert]::IsTrue($host.Version.Major -gt 2)

$hub_host = '127.0.0.1'
$hub_port = '4444'

try {

  if ([bool]$PSBoundParameters['grid'].IsPresent) {
    $selenium = launch_selenium -browser $browser -grid -hub_host $hub_host -hub_port $hub_port
    Start-Sleep -Millisecond 500
  } else {
    $selenium = launch_selenium -browser $browser
  }

  $sessionid = $selenium.SessionId
} catch [exception]{
  # Method invocation failed because [OpenQA.Selenium.PhantomJS.PhantomJSDriver] doesn't contain a method named 'GetSessionId'.
  $ErrorMessage = $_.Exception.Message
  write-host $ErrorMessage
  $selenium.Quit()
  return
}


[void]$selenium.manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds(10))
write-host "Selenium url "$selenium.Url
[string]$base_url = 'https://www.facebook.com';
$selenium.Navigate().GoToUrl($base_url)
write-host "Selenium url "$selenium.Url



[NUnit.Framework.Assert]::IsTrue($sessionid -ne $null)

# https://github.com/davglass/selenium-grid-status/blob/master/lib/index.js
# call TestSessionStatusServlet.java
$sessionURL = ("http://{0}:{1}/grid/api/testsession?session={2}" -f $hub_host,$hub_port,$sessionid)
$req = [System.Net.WebRequest]::Create($sessionURL)
$resp = $req.GetResponse()
$reqstream = $resp.GetResponseStream()
$sr = New-Object System.IO.StreamReader $reqstream
$result = $sr.ReadToEnd()
$session_json_object = ConvertFrom-Json -InputObject $result
$session_json_object | Format-List

$proxyId = $session_json_object.proxyId

# calls ProxyStatusServlet.java
$proxyinfoURL = ('http://{0}:{1}/grid/api/proxy?id={2}' -f $hub_host,$hub_port,$proxyId)

$req = [System.Net.WebRequest]::Create($proxyinfoURL)
$resp = $req.GetResponse()
$reqstream = $resp.GetResponseStream()
$sr = New-Object System.IO.StreamReader $reqstream
$result = $sr.ReadToEnd()

$proxyinfo_json_object = ConvertFrom-Json -InputObject $result
$proxyinfo_json_object | Format-List

$window_handle = $selenium.CurrentWindowHandle

Write-Output ("CurrentWindowHandle = {0}`n" -f $window_handle)

$selenium_capabilities = $selenium.Capabilities
$selenium_capabilities | Format-List

# Cleanup
cleanup ([ref]$selenium)

return
