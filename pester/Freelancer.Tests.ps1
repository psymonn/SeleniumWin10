param (
    [String]$browser="firefoxGrid"
)

write-host "browser chosen: " $browser
$DebugPreference = 'Continue'
Describe "$browser Freelancer" {
    #Import-Module (Join-Path $PSScriptRoot "Selenium.psm1")
    #Import-Module (Resolve-Path ".\PSHitchhiker\PSHitchhiker.psm1") -Force
    #$VerbosePreference = 'continue'
    #$ErrorActionPreference = 'Continue'

    # $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    # $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path)
    # write-host "sut =" $sut
    # write-host "here =" $here
    # $here = $here -replace 'pester', ''
    # write-host "here =" $here
    # write-host "$here\$sut"

    # Import-Module (Resolve-Path ".\SeleniumWin10.psd1") -Force
    import-module .\SeleniumWin10.psd1 -force
    #Import-Module SeleniumWin10.psd1

    [string] $username = 'psymon6ng'
    [string] $password = 'Test01'
    [string] $base_url = 'https://www.freelancer.com'

    # $script:selenium = $null
    # BeforeAll {
    #     $script:selenium = launch_selenium -browser $browser
    # }

    $selenium = launch_selenium -browser $browser -hub_host 'http://eucdevjnk02' -ErrorAction Stop 
    Context "Login to Freelancer" {
        It "Launch $browser" {
            $selenium | Should Not BeNullOrEmpty
        }

        Start-Sleep -Millisecond 1000
        $selenium.Navigate().GoToUrl($base_url)

        It "At Freelancer Page " {
            $selenium.Url | Should Match $base_url
        }

        [OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)
        [string]$login_css_selector = "a.LoginSection-btn[href='/login']"
        [object]$login_button_element = find_element -css_selector $login_css_selector -selenium $selenium
        highlight ([ref]$selenium) ([ref]$login_button_element)

        $logIn = Get-SeElementAttribute -Element  $login_button_element -Attribute "text"

        It "At login screen" {
            $logIn | should be "Log In"
        }

        [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()

        # [string]$login_div_selector = "input#username"
        # [object]$login_div_element = find_element -css_selector $login_div_selector -selenium $selenium
        # highlight ([ref]$selenium) ([ref]$login_div_element)

        [string]$login_username_selector = "input#username"
        [string]$login_username_data = $username
        [object]$login_username_element = find_element -css_selector $login_username_selector -selenium $selenium
        highlight ([ref]$selenium) ([ref]$login_username_element)

        $login_username_element.Clear()
        $login_username_element.SendKeys($login_username_data)

        $id = Get-SeElementAttribute -Element  $login_username_element -Attribute "id"
        $type = Get-SeElementAttribute -Element $login_username_element -Attribute "type"

        It "Enter username" {
           $id | should be "username"
            $type | Should Not BeNullOrEmpty
        }

        [string]$login_password_selector = "input#password"
        [string]$login_password_data = $password
        [object]$login_password_element = find_element -css_selector $login_password_selector -selenium $selenium
        highlight ([ref]$selenium) ([ref]$login_password_element)
        $login_password_element.Clear()
        $login_password_element.SendKeys($login_password_data)

        $name = Get-SeElementAttribute -Element  $login_password_element -Attribute "name"
        $type = Get-SeElementAttribute -Element $login_password_element -Attribute "type"

        It "Enter password" {
            $name | should be "password"
            $type | Should Not BeNullOrEmpty
        }


        [string]$login_submit_selector = "form.user-login-form[name='LoginForm.form'] button[id='login_btn']"
        [object]$login_submit_element = find_element -css_selector $login_submit_selector -selenium $selenium
        highlight ([ref]$selenium) ([ref]$login_submit_element)
        $login_submit_element.Click()

        $wait_seconds = 15
        $wait_polling_interval = 300
        [OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
        $wait.PollingInterval = $wait_polling_interval

        [string]$profile_figure_selector = "figure.ImgContainer.ng-star-inserted img[src*='unknown.png']"
        try {
            [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($profile_figure_selector)))
        } catch [exception]{
            Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$profile_figure_selector)
        }

        [object]$profile_figure_element = find_element -css_selector $profile_figure_selector -selenium $selenium
        highlight ([ref]$selenium) ([ref]$profile_figure_element)

        It "Logged into Dashboard" {
            $selenium.url | Should Be 'https://www.freelancer.com/dashboard'
        }
    }

    Start-Sleep -Millisecond 1000
    $selenium.Navigate().GoToUrl(('{0}/jobs/myskills/1' -f $base_url))

    Context "Navigate to different Page" {
        It "Goto search page" {
            $selenium.url | Should Not Be 'https://www.freelancer.com/dashboard'
        }

    }

    cleanup ([ref]$selenium)
    #Stop-SeDriver([ref]$selenium)
    # AfterAll {
    #     cleanup ([ref]$selenium)
    # }

}
