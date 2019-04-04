param (
    [String]$browser="firefox"
)

Describe "$browser Freelancer" {
    #Import-Module (Join-Path $PSScriptRoot "Selenium.psm1")
    #Import-Module (Resolve-Path ".\PSHitchhiker\PSHitchhiker.psm1") -Force
    $DebugPreference = 'Continue'

    # $here = Split-Path -Parent $MyInvocation.MyCommand.Path
    # $sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) 
    # write-host "sut =" $sut
    # write-host "here =" $here
    # $here = $here -replace 'pester', ''
    # write-host "here =" $here
    # write-host "$here\$sut"

    # Import-Module (Resolve-Path ".\SeleniumWin10.psd1") -Force
    import-module .\SeleniumWin10.psd1 -force

    [string] $base_url = 'https://www.freelancer.com'
    $selenium = launch_selenium -browser $browser
    $selenium.Navigate().GoToUrl($base_url)
}