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

      [string]$shared_assemblies_path = 'F:\Data\Git\Selenium\lib40\'
      [string[]]$shared_assemblies = @(
        'WebDriver.dll',
        'WebDriver.Support.dll',
        'Newtonsoft.Json.dll'
        #'nunit.core.dll',
        #'nunit.framework.dll'
        )


    $env:SHARED_ASSEMBLIES_PATH = $shared_assemblies_path

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
        [bool]$use_remote_driver = $false,
        [switch]$debug
    )


    $script:selenium_path = 'F:\Data\Git\Selenium\lib40\'

    # Write-Debug (Get-ScriptDirectory)
    $use_remote_driver = [bool]$PSBoundParameters['grid'].IsPresent
    # Write-Debug (Get-ScriptDirectory)
    $run_headless = [bool]$PSBoundParameters['headless'].IsPresent
    if ($run_headless) {
        write-debug 'launch_selenium: Running headless'
    }

    # SELENIUM_DRIVERS_PATH environment overrides parameter, for Team City
    #$selenium_path =  'c:\java\selenium'
    if (($env:SELENIUM_PATH -ne $null) -and ($env:SELENIUM_PATH -ne '')) {
        $script:selenium_path = $env:SELENIUM_PATH
    }

    # SHARED_ASSEMBLIES_PATH environment overrides parameter, for Team City/Jenkins
    if (($env:SHARED_ASSEMBLIES_PATH -ne $null) -and ($env:SHARED_ASSEMBLIES_PATH -ne '')) {
        $shared_assemblies_path = $env:SHARED_ASSEMBLIES_PATH
    }

    #$selenium_drivers_path = 'c:\java\selenium'
    # SELENIUM_DRIVERS_PATH environment overrides parameter, for Team City/Jenkinks
    if (($env:SELENIUM_DRIVERS_PATH -ne $null) -and ($env:SELENIUM_DRIVERS_PATH -ne '')) {
        $script:selenium_path = $env:SELENIUM_DRIVERS_PATH
    }
    elseif (($env:SELENIUM_PATH -ne $null) -and ($env:SELENIUM_PATH -ne '')) {
        $script:selenium_path = $env:SELENIUM_PATH
    }

    # write-Debug "load_shared_assemblies -shared_assemblies_path ${shared_assemblies_path} -shared_assemblies ${shared_assemblies}"
    # start-sleep -milliseconds 1000

   # load_shared_assemblies -shared_assemblies_path $shared_assemblies_path -shared_assemblies $shared_assemblies


    $uri = [System.Uri](('http://{0}:{1}/wd/hub' -f $hub_host, $hub_port))
    if ($DebugPreference -eq 'Continue') {
        if ($use_remote_driver) {
            Write-Host 'Using remote driver'
        }
        else {
            Write-Host 'Using standalone driver'
        }
    }

    $driver = $null
    if ($browser -ne $null -and $browser -ne '') {
        if ($use_remote_driver) {

            try {
                $connection = (New-Object Net.Sockets.TcpClient)
                $connection.Connect($hub_host, [int]$hub_port)
                Write-Debug 'Grid is already running'

                $connection.Close()
            }
            catch {
                Write-Debug 'Launching grid'
                Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /c ${script:selenium_path}\hub.cmd"
                Start-Process -FilePath 'C:\Windows\System32\cmd.exe' -argumentList "start cmd.exe /c ${script:selenium_path}\node.cmd"
                Start-Sleep -Millisecond 5000
            }

        }
        else {
            # launching Selenium jar in standalone execution is not needed

            # adding driver folder to the path environment
            if (-not (Test-Path $script:selenium_path)) {
                throw "Folder $script:selenium_path} does not exist, cannot be added to $env:PATH"
            }

            # See if the new folder is already in the path.
            if ($env:PATH | Select-String -SimpleMatch $script:selenium_path) {
                Write-Debug "Folder $script:selenium_path} already within `$env:PATH"

            }

            # Set the new PATH environment
            $env:PATH = $env:PATH + ';' + $script:selenium_path
        }

    }

    write-debug "Launching ${browser}"

    if ($browser -match 'firefox') {
        if ($use_remote_driver) {
            $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()
            $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri, $capability)

        }
        else {
            # Need constructior with firefoxOptions for headless
            if ($run_headless) {
                # https://stackoverflow.com/questions/46848615/headless-firefox-in-selenium-c-sharp
                [OpenQA.Selenium.Firefox.FirefoxOptions]$firefox_options = new-object OpenQA.Selenium.Firefox.FirefoxOptions
                $firefox_options.addArguments('--headless')
                $selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($firefox_options)
            }
            else {
                # $driver_environment_variable = 'webdriver.gecko.driver'
                # if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)) {
                #      [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${script:selenium_path}\geckodriver.exe")
                #     #[Environment]::SetEnvironmentVariable( $driver_environment_variable, "F:\Data\Git\Selenium\lib40\geckodriver.exe")
                # }
                # #  $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Firefox()

                # [object]$profile_manager = New-Object OpenQA.Selenium.Firefox.FirefoxProfileManager
                # #[OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles[1]
                # #$profile = Join-Path $PSScriptRoot "Assets\ff-profile\rust_mozprofile.YwpEBLY3hCRX"
                # $profile = [OpenQA.Selenium.Firefox.FirefoxProfile]::new("xyzProfile")

                # [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = $profile_manager.GetProfile($profile)
                # [OpenQA.Selenium.Firefox.FirefoxProfile]$selected_profile_object = New-Object OpenQA.Selenium.Firefox.FirefoxProfile ($profile)
                # #  $selected_profile_object.setPreference('general.useragent.override',"Mozilla/5.0 (Windows NT 6.3; rv:36.0) Gecko/20100101 Firefox/34.0")

                # # https://code.google.com/p/selenium/issues/detail?id=40

                # $selected_profile_object.setPreference('browser.cache.disk.enable', $false)
                # $selected_profile_object.setPreference('browser.cache.memory.enable', $false)
                # $selected_profile_object.setPreference('browser.cache.offline.enable', $false)
                # $selected_profile_object.setPreference('network.http.use-cache', $false)
                #$selected_profile_object.setPreference('FirefoxBinaryPath', "F:\Data\Git\Selenium\lib40\geckodriver.exe")

                 #$selenium = New-Object OpenQA.Selenium.Firefox.FirefoxDriver ($selected_profile_object)
               #$driver = New-Object OpenQA.Selenium.Firefox.FirefoxDriver;

               $selenium= New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
               $selenium.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(10)


               #$Driver = New-Object -TypeName "OpenQA.Selenium.Firefox.FirefoxDriver"
             #  $selenium.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(10)

            #   $base_url = "http://www.google.com"

              # $selenium.Navigate().GoToUrl($base_url)

                #[OpenQA.Selenium.Firefox.FirefoxProfile[]]$profiles = $profile_manager.ExistingProfiles

                # [NUnit.Framework.Assert]::IsInstanceOfType($profiles , new-object System.Type( FirefoxProfile[]))
                # [NUnit.Framework.StringAssert]::AreEqualIgnoringCase($profiles.GetType().ToString(),'OpenQA.Selenium.Firefox.FirefoxProfile[]')
            }
        }
    }
    elseif ($browser -match 'chrome') {
        $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
        if ($use_remote_driver) {
            $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri, $capability)
        }
        else {
            $driver_environment_variable = 'webdriver.chrome.driver'
            if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)) {
                [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${script:selenium_path}\chromedriver.exe")
            }

            # override

            # Oveview of extensions
            # https://sites.google.com/a/chromium.org/chromedriver/capabilities

            # Profile creation
            # https://support.google.com/chrome/answer/142059?hl=en
            # http://www.labnol.org/software/create-family-profiles-in-google-chrome/4394/
            # using Profile
            # http://superuser.com/questions/377186/how-do-i-start-chrome-using-a-specified-user-profile/377195#377195


            # origin:
            # http://stackoverflow.com/questions/20401264/how-to-access-network-panel-on-google-chrome-developer-toools-with-selenium

            [OpenQA.Selenium.Chrome.ChromeOptions]$options = New-Object OpenQA.Selenium.Chrome.ChromeOptions

            if ($run_headless) {
                $width = 1200;
                $height = 800;
                # https://stackoverflow.com/questions/45130993/how-to-start-chromedriver-in-headless-mode
                $options.addArguments([System.Collections.Generic.List[string]]@('--headless', "--window-size=${width}x${height}", '-disable-gpu'))
            }
            else {
                # TODO: makse configurable through a switch
                #   $options.addArguments('start-maximized')
                # no-op option - re-enforcing the default setting
                $options.addArguments(('user-data-dir={0}' -f ("${env:LOCALAPPDATA}\Google\Chrome\User Data" -replace '\\', '/')))
                # if you like to specify another profile parent directory:
                # $options.addArguments('user-data-dir=c:/TEMP');

                $options.addArguments('--profile-directory=Default')

                [OpenQA.Selenium.Remote.DesiredCapabilities]$capabilities = [OpenQA.Selenium.Remote.DesiredCapabilities]::Chrome()
                $capabilities.setCapability([OpenQA.Selenium.Chrome.ChromeOptions]::Capability, $options)
            }
            $locale = 'en-us'
            # http://knowledgevault-sharing.blogspot.com/2017/05/selenium-webdriver-with-powershell.html
            $options.addArguments([System.Collections.Generic.List[string]]@('--allow-running-insecure-content', '--disable-infobars', '--enable-automation', '--kiosk', "--lang=${locale}"))
            $options.AddUserProfilePreference('credentials_enable_service', $false)
            $options.AddUserProfilePreference('profile.password_manager_enabled', $false)
            $selenium = New-Object OpenQA.Selenium.Chrome.ChromeDriver($options)
        }
    }
    elseif ($browser -match 'ie') {
        if ($use_remote_driver) {
            $capability = [OpenQA.Selenium.Remote.DesiredCapabilities]::InternetExplorer()
            if ($version -ne $null -and $version -ne 0) {
                $capability.setCapability('version', $version.ToString());
            }

            # $capability.setCapability(InternetExplorerDriver.ENABLE_ELEMENT_CACHE_CLEANUP, true)
            # $capability.setCapability(InternetExplorerDriver.IE_ENSURE_CLEAN_SESSION, $true)
            $selenium = New-Object OpenQA.Selenium.Remote.RemoteWebDriver ($uri, $capability)
        }
        else {
            <#
        NOTE:
        New-Object : Exception calling ".ctor" with "1" argument(s): "Unexpected error launching Internet Explorer. Browser zoom level was set to 75%. It should be
        #>
            $driver_environment_variable = 'webdriver.ie.driver'
            if (-not [Environment]::GetEnvironmentVariable($driver_environment_variable, [System.EnvironmentVariableTarget]::Machine)) {
                [Environment]::SetEnvironmentVariable( $driver_environment_variable, "${script:selenium_path}\chromedriver.exe")
            }
            $selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver($script:selenium_path)

        }
        else {
            throw "unknown browser choice:${browser}"
        }
    }
    $selenium
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
