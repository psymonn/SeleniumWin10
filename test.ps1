#. .\selenium_common.psm1

#cd "f:\GitHub\Source\powershell_selenium\powershell\"
# File Test.ps1:
#Import-Module -Name .\SeleniumWin10.psd1 -Force
#import-module -name .\selenium_common.psm1 -force

#$VerbosePreference = 'continue'
$DebugPreference = 'Continue'

#Write-Host "Global VerbosePreference: $global:VerbosePreference"
#Write-Host "TestModules.ps1 Script VerbosePreference: $script:VerbosePreference"

#Launch_selenium "ie"

#.\booking_com_search.ps1 "ie"
#.\freelancer_search.ps1 "ie" -password "hello"
#launch_selenium
#./canvas_actions.ps1 "firefox"
#./booking_com_search.ps1 "firefox"
#./refresh_windows_key.ps1 "firefox"
#./keynote_s1.ps1 -password "noee" -debug
#./F:\GitHub\Source\SeleniumWin10\test.ps1 "firefox" -password "lalal"
#./freelancer_search.xpath.ps1 "firefox" -password "Test01" -debug
#./get_sessionid "firefoxGrid" -grid -debug
#./samples/get_sessionid "firefoxgrid" -debug
#./scraping_projects "firefox" -password "Test01" -debug
#./iframes.ps1 "firefox"
#./freelancer_search.css.ps1 "firefox" -password "Test01" -debug
#F:\GitHub\Source\SeleniumWin10\test.ps1 "firefox" -password "Test01"
#./pester/FreelancerTests.ps1
./FreelancerTests.ps1 "firefoxGrid"