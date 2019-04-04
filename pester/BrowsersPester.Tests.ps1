param (
    [String]$browser
)

# Describe "ValidateWebSite" {

#     # Check if IIS is installed
#     It "IIS Service Started" {
#         $Result = Remotely { Get-Service W3SVC }
# 	$Result.Status | Should be "Running"
#     }

#     # Check if Website is created
#     It "IIS Web Site started" {
#         $Result = Remotely { param($IISSite) Get-Website -Name $IISSite } -ArgumentList $IISSite
# 	$Result.State | Should be "Started"
#     }

#     # Check if Application exsists
#     It "IIS Application Pool Started" {
#         $Result = Remotely { param($IISPool) Get-WebAppPoolState -name $IISPool }  -ArgumentList $IISPool
# 	$Result.Value | Should be "Started"
#     }
# }



# https://gist.github.com/smaglio81/df4a7a5ed5bf8ebc3d859577536e4b27
# http://stackoverflow.com/questions/1183183/path-of-currently-executing-powershell-script
#$root = Split-Path $MyInvocation.MyCommand.Path -Parent;
#$moduleRoot = Resolve-Path "$PSScriptRoot\.."
#$moduleName = Split-Path $moduleRoot -Leaf



Describe -Tag "UI","Public" -Name "$browser" {

    if(-not $global:RunningInvokePester) {
        Write-Host "Reloading Modules"

        $Environment = "dev"

        #Import-Module SeleniumExtensions
        Import-Module Selenium
        Import-Module Pester
        #. $PSScriptRoot\Wait-UntilElementLoaded.ps1
        #import-Module $PSScriptRoot\PSSelenium\Selenium.psm1
        #import-Module C:\Data\Git\Selenium\PSSelenium\Selenium.psm1
        import-module PSSelenium
    }


    Context "$browser Simple Search 1" {
        BeforeAll {
            if($Environment -eq "prod") {
            $script:url = "https://somesite.{env}.subgroup.domain.com" -f $Environment
            } else {
                $script:url = "https://www.google.com"
            }

            #$script:driver = Start-SeChrome
            $script:driver = Start-SeChrome -Arguments "headless", "incognito"
        }

        It "$browser Search - Returns Results" {
            Enter-SeUrl -Driver $script:driver -Url $script:url

            (Find-SeElement -Driver $script:driver -Name "q").SendKeys("lookups")
            #(Find-SeElement -Driver $script:driver -Name "btnk").Submit() | Out-File "C:\Data\Git\Selenium\GoogleSearchResults.html" -Force
           # (Find-SeElement -Driver $script:driver -Name "btnk").Submit()

            #Wait-UntilElementLoaded -Driver $script:driver -ClassName "navbar-brand"

           # $searchBar = Find-SeElement -Driver $script:driver -Id "search-terms"
           # Send-SeKeys -Element $searchBar -Keys "lookups"

            #$searchBtn = Find-SeElement -Driver $script:driver -Id "search-button"
            #Invoke-SeClick -Element $searchBtn

            #Wait-UntilElementLoaded -Driver $script:driver -XPath "//div[@id='service-small-info-1']/div[@class='highlights']/ul"

            #$firstResult = Find-SeElement -Driver $script:driver -XPath "//div[@id='service-small-info-1']/div[@class='highlights']"

            #$firstResult.Text | Should Match "/classifications \(Get\)"



            # Make use of Selenium's class methods to manage our browser at will
        }

        AfterAll {
            Stop-SeDriver -Driver $script:driver
        }
    }

    Context "$browser Simple Search 2 " {
        BeforeAll {
            $script:url = "https://www.bing.com"
            $script:driver = Start-SeChrome
            #$script:driver = Start-SeChrome -Arguments "headless", "incognito"
            #Open-WebPage  "www.bing.com"
        }

        It "$browser Should Find CheesecakeFactory ByNameInBingSearch" {
            Enter-SeUrl -Driver $script:driver -Url $script:url
            #Wait total of 30sec to find element by Css selector, further validate element exist in DOM
            #Wait-UntilElementVisible -Selector Css -Value "#sb_form_q"

            #$driver = New-Object OpenQA.Selenium.Chrome.Chromedriver
            #Validate-ElementExists -Selector Css -Value "#sb_form_q"
            $driverWait = New-Object -TypeName OpenQA.Selenium.Support.UI.WebDriverWait($script:driver, (New-TimeSpan -Seconds 10))
            $driverWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementIsVisible([OpenQA.Selenium.By]::CssSelector("#sb_form_q")))
            $driverWait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector("#sb_form_q")))

            #$Driver.FindElementByName("q").SendKeys("mavericksevmont tech blog")
            #$Driver.FindElementByName("btnK").Submit()

            #Find-SeElement -XPath ".//*[@id='sb_form_q']"
            #Send-SeKeys -Keys "Cheesecake Factory"




            #Insert text into a control on the page using xpath
            #Insert-Text -Selector XPath -Value ".//*[@id='sb_form_q']" -string "Cheesecake Factory"

            #Click a control using css selector
            ##Click-Item -Selector Css -Value "#sb_form_go"
            #Invoke-SeClick -Element "#sb_form_go"

            #Wait for 30sec to find element by Css selector
            ##Wait-UntilElementVisible -Selector Css -Value ".b_entityTitle"

            #Validate Element css element contains text (supports regex)
            ##$firstResult2.Text = Validate-TextExists -Selector Css -Value ".b_entityTitle"

            ##$firstResult2.Text | Should Match "The Cheesecake Factory"
        }

        AfterAll {
            Stop-SeDriver -Driver $script:driver
        }

    }
}



# function isElementPresent($locator,[switch]$byClass,[switch]$byName){
#     try{
#         if($byClass){
#             $null=$script:driver.FindElementByClassName($locator)
#         }
#         elseif($byName){
#             $null=$script:driver.FindElementByName($locator)
#         }
#         else{
#             $null=$script:driver.FindElementById($locator)
#         }
#         return $true
#     }
#     catch{
#         return $false
#     }
# }

# while(!(isElementPresent 'q' -byName)){
#     sleep 1
# }
# $driver.FindElementByName('q')
