Function TestBrowsers{
	#param($browser)
param(
   [String] $browser
)

try{
	#write-host "Well, did we get $Args passed in correctly?"
	write-host "Well, did we get $VariableA and $VariableB passed in correctly?"

	<# WebDrive dll#> 
	Add-Type -Path "F:\Data\Git\Selenium\lib40\WebDriver.dll";

	#$browser = $Args -join " ";
	#$browser = "Firefox";
	#write-host "Arugrments: $Args"
	write-host "Browser chosen: $browser"

	$chromedriver_path = "F:\Data\Git\Selenium\lib40";

	<# The Internet Explorer Driver Server(32bit) #>
	$iedriver32_path   = "F:\Data\Git\Selenium\lib40";

	<# The Internet Explorer Driver Server(64bit#>
	$iedriver64_path   = "F:\Data\Git\Selenium\lib40"

	$MicrosoftWebDriver = "F:\Data\Git\Selenium\lib40";

	<# Selenium Grid HubのURL #>
	$selenium_grid_hub = New-Object System.Uri("http://eucdevjnk01:4444/wd/hub")

	switch ($browser)
	{
	    <# Mozilla Firefox #>
	    "Firefox" {
		    $driver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver;
		    #$driver.Manage().Window.Maximize();
		}
	    <# Google Chrome #>
	    "chrome" {
		    $driver = New-Object OpenQA.Selenium.Chrome.ChromeDriver($chromedriver_path);
		    #$driver.Manage().Window.Maximize();
		}
	    <# Internet Explorer Win32#>
	    "ie32" {
		    $driver = New-Object OpenQA.Selenium.IE.InternetExplorerDriver($iedriver32_path);
		    #$driver.Manage().Window.Maximize();
		}
	    <# Internet Explorer x64#>
	    "ie64" {
		    $driver = New-Object OpenQA.Selenium.IE.InternetExplorerDriver($iedriver64_path);
		    #$driver.Manage().Window.Maximize();
		}
	    <# Edge #>
	    "Edge" {
		    $driver = New-Object OpenQA.Selenium.Edge.EdgeDriver($MicrosoftWebDriver);
		    #$driver.Manage().Window.Maximize();
		}

	    <# Mozilla Firefox(Selenium Grid) #>
	    "MozillaFirefoxGrid" {
		    $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
		    $capability.SetCapability("browserName", "firefox");
		    $capability.SetCapability("platform",    "WINDOWS");
		    #$capability.SetCapability("version",     "43.0");
		    $driver = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($selenium_grid_hub, $capability);
		    #$driver.Manage().Window.Maximize();
		}
	    <# Goofle Chrome(Selenium Grid) #>
	    "GoogleChromeGrid" {
		    $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
		    $capability.SetCapability("browserName", "chrome");
		    $capability.SetCapability("platform",    "WINDOWS");
		   # $capability.SetCapability("version",     "47.0.2526.106 m (64-bit)");
		    $driver = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($selenium_grid_hub, $capability);
		    #$driver.Manage().Window.Maximize();
		}
	    <# AndroidのGoofle Chrome(Selenium Grid) #>
	    "AndroidGrid" {
		    $options = @{}
		    $options.Add("androidPackage", "com.android.chrome")

		    $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
		    $capability.SetCapability("browserName",   "chrome");
		    $capability.SetCapability("platform",      "WINDOWS");
		    $capability.SetCapability("version",       "android local");
		    $capability.setCapability("chromeOptions", $options);
		    $driver = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($selenium_grid_hub, $capability);
		}
	    <# Internet Explorer x64 (Selenium Grid) #>
	    "InternetExplorerGrid" {
		    $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
		    $capability.SetCapability("browserName", "internet explorer");
		    $capability.SetCapability("platform",    "WINDOWS");
		    #$capability.SetCapability("version",     "11.0 X64");
		    $driver = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($selenium_grid_hub, $capability);
		    #$driver.Manage().Window.Maximize();
		}
	    <# Mozilla Firefox #>
	    default {
		    #$browser = "Firefox";
		    #$driver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver;
		    #$driver.Manage().Window.Maximize();
		    write-host "you have reached default!"
		}
	
	
	
	}

	<# Google #>
	#$driver.Url = "http://www.google.co.jp/";

	$base_url = 'http://www.google.com/'
	$driver.Navigate().GoToUrl($base_url)
	$driver.Navigate().Refresh()
	#$driver.Manage().Window.Maximize()

	Start-Sleep -s 3

	$driver.Close();
	$driver.Dispose();

}catch [System.SystemException] {
       $ErrorMessage = $_.Exception.Message
       write-host $ErrorMessage
        $driver.Close();
        $driver.Dispose();
       exit 1
    }	
}
