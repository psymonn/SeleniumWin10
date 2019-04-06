[System.Reflection.Assembly]::LoadFrom("F:\Data\Git\Selenium\lib40\WebDriver.dll")
[System.Reflection.Assembly]::LoadFrom("F:\Data\Git\Selenium\lib40\WebDriver.Support.dll")

$obj_accel = [PowerShell].Assembly.GetType("System.Management.Automation.TypeAccelerators")
$obj_accel::Add("AList", [System.Collections.ArrayList])
$obj_accel.GetFields([System.Reflection.BindingFlags]"static, nonpublic") | out-null

$obj_accel.GetField("userTypeAccelerators", [System.Reflection.BindingFlags]"Static,NonPublic").GetValue($obj_accel)

$builtinField = $obj_accel.GetField("builtinTypeAccelerators", [System.Reflection.BindingFlags]"Static,NonPublic")
$builtinField.SetValue($builtinField, $obj_accel::Get)

# add accelerators
$obj_accel::Add('RemoteWebDriver', [OpenQA.Selenium.Remote.RemoteWebDriver])
$obj_accel::Add('ChromeDriver', [OpenQA.Selenium.Chrome.ChromeDriver])
$obj_accel::Add('WebDriverWait', [OpenQA.Selenium.Support.UI.WebDriverWait])
$obj_accel::Add('ExpectedConditions', [OpenQA.Selenium.Support.UI.ExpectedConditions])
$obj_accel::Add('By', [OpenQA.Selenium.By])
$obj_accel::Add('Actions', [OpenQA.Selenium.Interactions.Actions])
$obj_accel::Add('SelectElement', [OpenQA.Selenium.Support.UI.SelectElement])

#list all the added accelerators
[psobject].Assembly.GetType("System.Management.Automation.TypeAccelerators")::Get

#example of usage
$selenium = New-Object ChromeDriver
$selenium.Navigate().GoToUrl('https://www.google.com')
$selenium.Manage().Timeouts()

#example of usage:
$wait = New-Object WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds(10))
$wait.PollingInterval = 150

$selenium.Navigate().GoToUrl('https://ozbargain.com.au')
