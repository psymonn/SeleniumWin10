<#
.SYNOPSIS
	Loads calller-provided list of .net assembly dlls or fails with a custom exception

.DESCRIPTION
	Loads calller-provided list of .net assembly dlls or fails with a custom exception
.EXAMPLE
	load_shared_assemblies -shared_assemblies_path 'c:\tools' -shared_assemblies @('WebDriver.dll','WebDriver.Support.dll','nunit.framework.dll')
.LINK

.NOTES

	VERSION HISTORY
	2015/06/22 Initial Version
#>

[string]$script:shared_assemblies_path = 'F:\Data\Git\Selenium\lib40\'
[string[]]$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll',
  'Newtonsoft.Json.dll',
  'nunit.core.dll',
  'nunit.framework.dll'
  )


$env:SHARED_ASSEMBLIES_PATH = $script:shared_assemblies_path

$script:shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
pushd $script:shared_assemblies_path
$shared_assemblies | ForEach-Object {

  if ($host.Version.Major -gt 2){
    Unblock-File -Path $_;
  }
  write-output $_
  Add-Type -Path $_
  }
popd


<#
.SYNOPSIS
	Start Selenium
.DESCRIPTION
	Start Selenium

.EXAMPLE
    $selenium = launch_selenium -browser 'chrome' -hub_host -hub_port
    Will launch the selenium java hub and slave locally using batch commands or will connect to remote host and port
    $selenium = launch_selenium -browser 'chrome' -headless
    Will launch chrome in headless mode via the selenium driver, chromedriver
.LINK


.NOTES
	VERSION HISTORY
	2015/06/07 Initial Version
  ... misc untracted updates
	2018/07/26 added Headless support (only tested with Chrome))
#>
function launch_selenium {
    param(
        [string]$browser = '',
        [switch]$grid,
        [switch]$headless,
        [int]$version,
        [string]$hub_host = '127.0.0.1',
        [string]$hub_port = '4444',
        [switch]$debug
    )

    # Write-Debug (Get-ScriptDirectory)
    $use_remote_driver = [bool]$PSBoundParameters['grid'].IsPresent
    # Write-Debug (Get-ScriptDirectory)
    $run_headless = [bool]$PSBoundParameters['headless'].IsPresent
    if ($run_headless) {
        write-debug 'launch_selenium: Running headless'
    }

    $uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host, $hub_port))
    if ($DebugPreference -eq 'Continue') {
        if ($use_remote_driver) {
            Write-Host 'Using remote driver'
        }
        else {
            Write-Host 'Using standalone driver'
        }
    }

    $selenium = $null
    if ($browser -ne $null -and $browser -ne '') {

        if ($browser -Like "*Grid*") {

            try {
                $connection = (New-Object Net.Sockets.TcpClient)
                $connection.Connect($hub_host, [int]$hub_port)
                Write-Debug 'Grid is already running'

                $connection.Close()
            }
            catch {
                Write-Debug 'Launching grid'
                Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /k $($script:shared_assemblies_path)\hub.cmd"
                Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /k $($script:shared_assemblies_path)\node.cmd"
                Start-Sleep -Millisecond 5000
            }

        }
        else {
            # launching Selenium Sever jar in standalone execution is not needed

            # adding driver folder to the path environment
            if (-not (Test-Path $script:shared_assemblies_path)) {
                throw "Folder $script:shared_assemblies_path} does not exist, cannot be added to $env:PATH"
            }

            # See if the new folder is already in the path.
            if ($env:PATH | Select-String -SimpleMatch $script:shared_assemblies_path) {
                Write-Debug "Folder $script:shared_assemblies_path} already within `$env:PATH"

            }else{
              # Set the new PATH environment
              $env:PATH = $env:PATH + ';' + $script:shared_assemblies_path
            }
        }

    }


    try{
        write-host "Browser chosen: $browser"
        write-debug "Launching ${browser}"

        switch ($browser)
        {
            <# Mozilla Firefox #>
            "Firefox" {
                #about:profiles
                $driver_environment_variable = 'webdriver.gecko.driver'
                  if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)){
                     [Environment]::SetEnvironmentVariable( $driver_environment_variable, "$($script:shared_assemblies_path)\geckodriver.exe")
                     #[Environment]::SetEnvironmentVariable("webdriver.gecko.driver","F:\Data\Git\Selenium\lib40\geckodriver.exe")
                  }



                #[string]$profile = 'Selenium'
                [string]$profile = "qu48lvoe.FirefoxTestProfile"
                $roamingProfile = "C:\Users\TI\AppData\Roaming\Mozilla\Firefox\Profiles\qu48lvoe.FirefoxTestProfile"
                [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager

                #$file = New-Object newFile("\c:users\AppData\MozillaFirefoxProfile_name.default")
                [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile("qu48lvoe.FirefoxTestProfile")
                #[OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($roamingProfile)
                #$selected_profile_object.setPreference('general.useragent.override',"Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/34.0")

                # https://code.google.com/p/selenium/issues/detail?id=40
                <#
                 $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
                 $capability.SetCapability("browserName", "firefox");
                 $capability.SetCapability("platform",    "WINDOWS");
                 $capability.setCapability("marionette", $true)
                 #$capability.SetCapability("BinaryLocation","C:\Program Files\Mozilla Firefox\firefox.exe")
                 $selected_profile_object.setPreference('marionette', $true)
                 $selected_profile_object.setPreference('browser.cache.disk.enable', $false)
                 $selected_profile_object.setPreference('browser.cache.memory.enable', $false)
                 $selected_profile_object.setPreference('browser.cache.offline.enable', $false)
                 $selected_profile_object.setPreference('network.http.use-cache', $false)
                 $capability.setCapability([OpenQA.Selenium.Firefox.FirefoxDriver]::PROFILE, $selected_profile_object)
                 #>
                 $selenium = new-object OpenQA.Selenium.Firefox.FirefoxDriver($selected_profile_object)

                #$selenium = new-object OpenQA.Selenium.Firefox.FirefoxDriver($capability)

                #$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver;
                #$selenium.Manage().Window.Maximize();

            }
            <# Mozilla Firefox Headless #>
            "FirefoxHeadless" {
                [OpenQA.Selenium.Firefox.FirefoxOptions]$firefox_options = new-object OpenQA.Selenium.Firefox.FirefoxOptions
                $firefox_options.addArguments('--headless')
                $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($firefox_options)
            }
            <# Mozilla Firefox(Selenium Grid) #>
              "MozillaFirefoxGrid" {
              $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
              $capability.SetCapability("browserName", "firefox");
              $capability.SetCapability("platform",    "WINDOWS");
              #$capability.SetCapability("version",     "43.0");
              $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($uri, $capability);
              #$selenium.Manage().Window.Maximize();
            }
            <# Google Chrome #>
            "chrome" {
                [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\', '/')))
                # if you like to specify another profile parent directory:
                # $options.addArguments('user-data-dir=c:/TEMP');
                $options.addArguments('--profile-directory=Default')

                $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
                $capability.SetCapability("browserName", "chrome");
                $capability.SetCapability("platform",    "WINDOWS");
                $capability.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability, $options)
                $locale = 'en-us'
                # http://knowledgevault-sharing.blogspot.com/2017/05/selenium-webdriver-with-powershell.html
                $options.addArguments([System.Collections.Generic.List[string]]@('--allow-running-insecure-content', '--disable-infobars', '--enable-automation', '--kiosk', "--lang=${locale}"))
                $options.AddUserProfilePreference('credentials_enable_service', $false)
                $options.AddUserProfilePreference('profile.password_manager_enabled', $false)
                $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($options)
                #$selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver;
            }
            <# Google Chrome Healess #>
              "chromeHeadless" {
                  [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                  $width = 1200;
                  $height = 800;
                  # https://stackoverflow.com/questions/45130993/how-to-start-chromedriver-in-headless-mode
                  $options.addArguments([System.Collections.Generic.List[string]]@('--headless', "--window-size=${width}x${height}", '-disable-gpu'))
                  $locale = 'en-us'
                  # http://knowledgevault-sharing.blogspot.com/2017/05/selenium-webdriver-with-powershell.html
                  $options.addArguments([System.Collections.Generic.List[string]]@('--allow-running-insecure-content', '--disable-infobars', '--enable-automation', '--kiosk', "--lang=${locale}"))
                  $options.AddUserProfilePreference('credentials_enable_service', $false)
                  $options.AddUserProfilePreference('profile.password_manager_enabled', $false)
                  $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($options)
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
            <# Internet Explorer #>
            "ie" {
                $selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver;
                #$selenium.Manage().Window.Maximize();
            }
            <# Internet Explorer x64 (Selenium Grid) #>
            "ieGrid" {
                $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
                $capability.SetCapability("browserName", "internet explorer");
                $capability.SetCapability("platform",    "WINDOWS");
                #$capability.SetCapability("version",     "11.0 X64");
                $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($uri, $capability);
                #$selenium.Manage().Window.Maximize();
            }
            <# Edge #>
            "Edge" {
                $selenium = New-Object OpenQA.Selenium.Edge.EdgeDriver($script:shared_assemblies_path);
                #$selenium.Manage().Window.Maximize();
            }
            <# Mozilla Firefox #>
            default {
                $browser = "Firefox";
                $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver;
                #$selenium.Manage().Window.Maximize();
            }

        }

        #$selenium.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(10)
        return $selenium;

    }catch [System.SystemException] {
        $ErrorMessage = $_.Exception.Message
        write-host $ErrorMessage
        $selenium.Close();
        $selenium.Dispose();
        exit 1
    }
}


function custom_pause {
    param([bool]$fullstop)
    # Do not close Browser / Selenium when run from Powershell ISE
    if ($fullstop) {
      try {
        Write-Output 'pause'
        [void]$host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
      } catch [exception]{}
    } else {
      Start-Sleep -Millisecond 1000
    }
  }



<#
.SYNOPSIS
	Sets default timeouts with current Selenium session
.DESCRIPTION
	Sets default timeouts with current Selenium session

.EXAMPLE
    set_timeouts ([ref]$selenium) [-exlicit <explicit timeout>] [-page_load <page load timeout>] [-script <script timeout>]

.LINK


.NOTES

	VERSION HISTORY
	2015/06/21 Initial Version
#>


function set_timeouts {
    param(
      [System.Management.Automation.PSReference]$selenium_ref,
      [int]$explicit = 60,
      [int]$page_load = 60,
      [int]$script = 60
    )
    [void]($selenium_ref.Value.Manage().timeouts().ImplicitlyWait([System.TimeSpan]::FromSeconds($explicit)))
    [void]($selenium_ref.Value.Manage().timeouts().SetPageLoadTimeout([System.TimeSpan]::FromSeconds($pageload)))
    [void]($selenium_ref.Value.Manage().timeouts().SetScriptTimeout([System.TimeSpan]::FromSeconds($script)))
  }

  <#
.SYNOPSIS
	Determines script directory
.DESCRIPTION
	Determines script directory

.EXAMPLE
	$script_directory = Get-ScriptDirectory

.LINK
	# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed

.NOTES
	TODO: http://joseoncode.com/2011/11/24/sharing-powershell-modules-easily/
	VERSION HISTORY
	2015/06/07 Initial Version
#>
# use $debugpreference = 'continue'/'silentlycontinue' to show / hide debugging information

# http://poshcode.org/2887
# http://stackoverflow.com/questions/8343767/how-to-get-the-current-directory-of-the-cmdlet-being-executed
# https://msdn.microsoft.com/en-us/library/system.management.automation.invocationinfo.pscommandpath%28v=vs.85%29.aspx
# https://gist.github.com/glombard/1ae65c7c6dfd0a19848c
function Get-ScriptDirectory
{
  [string]$scriptDirectory = $null

  if ($host.Version.Major -gt 2) {
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



<#
.SYNOPSIS
	Stops Selenium
.DESCRIPTION
	Stops Selenium

.EXAMPLE
    cleanup ([ref]$selenium)
    Will tell selenium to stop the browser window
.LINK


.NOTES

	VERSION HISTORY
	2015/06/07 Initial Version
#>
function cleanup {
    param(
      [System.Management.Automation.PSReference]$selenium_ref
    )
    try {
      $selenium_ref.Value.Close()
      $selenium_ref.Value.Quit()
    } catch [exception]{
      # Ignore errors if unable to close the browser
      Write-Output (($_.Exception.Message) -split "`n")[0]

    }
  }

  function Stop-SeDriver {
    param(
        [System.Management.Automation.PSReference]$selenium_ref
    )

    $selenium.Dispose()
}
