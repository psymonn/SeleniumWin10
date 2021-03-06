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

[string]$script:shared_assemblies_path = 'C:\Data\Git\Selenium\lib40\'
[string[]]$shared_assemblies = @(
  'WebDriver.dll',
  'WebDriver.Support.dll'
  #'Newtonsoft.Json.dll',
  # 'nunit.core.dll',
  # 'nunit.framework.dll'
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
    [CmdletBinding()]
    param(
        [string]$browser = '',
     #   [switch]$grid,
     #   [switch]$headless,
     #   [int]$version,
        [string]$hub_host = '127.0.0.1',
        [string]$hub_port = '4444'
    #    [switch]$debug
    )

    # Write-Debug (Get-ScriptDirectory)
  #  $use_remote_driver = [bool]$PSBoundParameters['grid'].IsPresent
    # Write-Debug (Get-ScriptDirectory)
    #$run_headless = [bool]$PSBoundParameters['headless'].IsPresent
    #if ($run_headless) {
    if ($browser -Like "*Headless*") {
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

    write-host "env:JENKINS_HOME =" $env:JENKINS_HOME 
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
              Write-Debug ('Grid {0}:{1} has not been started, trying to start it now...' -f $hub_host, $hub_port)
              Write-Debug $_.Exception.Message
              #avoid running it in Jenkins
              
              if (($env:JENKINS_HOME -eq $null) -or ($env:JENKINS_HOME -eq '')) {

                  Write-Debug 'Launching grid'

                  #  $msbuild = 'F:\GitHub\Source\SeleniumWin10\batchFile.cmd'
                  #  start-Process -FilePath $msbuild -ArgumentList '192.168.0.7'

                      Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /k  ${PSScriptRoot}/grid/hub.cmd ${hub_host} ${hub_port}"
                      Start-Sleep -Millisecond 5000
                      Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /k  ${PSScriptRoot}/grid/node.cmd ${hub_host} ${hub_port}"
                      Start-Sleep -Millisecond 9000
                }
             }

        }
        else {
            # launching Selenium Sever jar in standalone execution is not needed

            # adding driver folder to the path environment
            if (-not (Test-Path $script:shared_assemblies_path)) {
                throw "Folder '$($script:shared_assemblies_path)' does not exist, cannot be added to $env:PATH"
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
                #https://support.mozilla.org/en-US/kb/profile-manager-create-and-remove-firefox-profiles
                #about:profiles
                #about:config

                <#
                  #https://github.com/SeleniumHQ/selenium/issues/5290
                  #Getting existing profile via option
                  #This method stuck at browser!
                  [string] $profile1 = "C:\Data\App\FirefoxProfile\CustomProfile2\glauvfze.Selenium"
                  [string] $profile2 = "F:\Data\App\FirefoxProfile\CustomProfile3\dlg74adr.Windows10Profile2"
                  [string] $profile3 = "C:\Users\TI\AppData\Local\Mozilla\Firefox\Profiles\f0gowlzy.default"
                  [string] $profile4 = "F:\Data\App\FirefoxProfile\CustomProfile4\qu48lvoe.FirefoxTestProfile\"

                  [OpenQA.Selenium.Firefox.FirefoxOptions]$firefox_options = new-object OpenQA.Selenium.Firefox.FirefoxOptions
                  #$firefox_options.BrowserExecutableLocation = "C:\Program Files\Mozilla Firefox\firefox.exe"
                  $firefox_options.BrowserExecutableLocation = "C:\\Program Files\\Firefox Developer Edition\\firefox.exe"
                  $firefox_options.addArguments("-profile", $profile4)
                  $firefox_options.setPreference('marionette', $true)
                  $firefox_options.setPreference('browser.cache.disk.enable', $false)
                  $firefox_options.setPreference('browser.cache.memory.enable', $false)
                  $firefox_options.setPreference('browser.cache.offline.enable', $false)
                  $firefox_options.setPreference('network.http.use-cache', $false)
                  $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($firefox_options)
                #>

                <#
                  #Getting existing profile via profile - didn't work, keep on produciing new profile after executed
                  [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager
                  [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile("qu48lvoe.FirefoxTestProfile")
                  $selenium = new-object OpenQA.Selenium.Firefox.FirefoxDriver($selected_profile_object)
                #>
                <#
                  #error: The file OpenQA.Selenium.Firefox.FirefoxProfile\geckodriver.exe does not exist
                  #it doesn't mean geckodrive.exe does not exist, it means something wrong with the firefoxprofile class
                  [string[]] $pathsToProfiles = Get-ChildItem "${env:LOCALAPPDATA}\Mozilla\Firefox\Profiles" | Where-Object {$_.name -like '*default'}
                  if ($pathsToProfiles.Length -ne 0) {
                    # FirefoxProfile profile = new FirefoxProfile(pathsToProfiles[0]);
                      [OpenQA.Selenium.Firefox.FirefoxProfile]$profile = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($pathsToProfiles[0])
                      #$profile.SetPreference("browser.tabs.loadInBackground", $false); // set preferences you need
                      $profile.SetPreference("webdriver.firefox.profile", $pathsToProfiles[0]);
                      $profile.SetPreference("browser.startup.homepage", "about:blank");
                      $profile.SetPreference("general.useragent.override", 'model.UserAgent')
                      $profile.EnableNativeEvents = $true
                      $profile.AcceptUntrustedCertificates = $true
                      $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($profile)
                  }
                #>
                $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver

            }
            <# Mozilla Firefox Headless #>
            "FirefoxHeadless" {
                [OpenQA.Selenium.Firefox.FirefoxOptions]$firefox_options = new-object OpenQA.Selenium.Firefox.FirefoxOptions
                $firefox_options.addArguments('--headless')
                $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver($firefox_options)
            }
            <# Mozilla Firefox(Selenium Grid) #>
              "FirefoxGrid" {
              $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
              $capability.SetCapability("browserName", "firefox");
              $capability.SetCapability("platform",    "WINDOWS");
              #$capability.setCapability("acceptInsecureCerts",$true)
              #$capability.SetCapability("version",     "43.0");
              $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($uri, $capability);
              #$selenium.Manage().Window.Maximize();
            }
            <# Google Chrome #>
            "chrome" {
                [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions
                $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\', '/')))
                # if you like to specify another profile parent directory:
                #$options.addArguments('user-data-dir=C:\temp\chromeprofile')
                $options.addArguments('--profile-directory=Default')
               #$options.addArguments('--profile-directory=Windows10ChromeProfile1')


                $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
                $capability.SetCapability("browserName", "chrome");
                $capability.SetCapability("platform",    "WINDOWS");
                $capability.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability, $options)
                $locale = 'en-us'
                # http://knowledgevault-sharing.blogspot.com/2017/05/selenium-webdriver-with-powershell.html
                #$options.addArguments([System.Collections.Generic.List[string]]@('--allow-running-insecure-content', '--disable-infobars', '--enable-automation', '--kiosk', "--lang=${locale}"))
                $options.addArguments([System.Collections.Generic.List[string]]@('--allow-running-insecure-content', '--disable-infobars', '--enable-automation', "--lang=${locale}"))
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
              "ChromeGrid" {
                  $capability = New-Object OpenQA.Selenium.Remote.DesiredCapabilities;
                  $capability.SetCapability("browserName", "chrome");
                  $capability.SetCapability("platform",    "WINDOWS");
                # $capability.SetCapability("version",     "47.0.2526.106 m (64-bit)");
                  $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver($uri, $capability);
                  #$driver.Manage().Window.Maximize();
            }
            <# Internet Explorer #>
            "ie" {
                $selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver;
                #$selenium.Manage().Window.Maximize();
            }
            <# Internet Explorer x64 (Selenium Grid) #>
            "IEGrid" {
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
        if ($selenium -ne $null) {
          $selenium.Close();
          $selenium.Dispose();
        
        }
        #exit 1
        #Write-Error "This is an error" -ErrorAction Stop
        #$PSCmdlet.WriteError($_)
        #Write-Error "Failed!: Selenium Webdriver could not be started"
        throw "Failed: Selenium Webdriver could not be started!`n $_"
        #return
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

    $selenium_ref.Dispose()
}
