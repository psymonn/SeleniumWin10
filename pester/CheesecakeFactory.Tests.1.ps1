param (
    [String]$browser
)

Describe "$browser Cheesecake Factory" {
    #Import-Module (Join-Path $PSScriptRoot "Selenium.psm1")
    Import-Module Selenium
    Context "Should Find Cheesecake Factory In BingSearch" {
        #$Driver = Start-SeFirefox
        $Driver = Start-SeChrome
        Enter-SeUrl -Driver $Driver -Url "http://www.bing.com"
        $Element = Find-SeElement -Driver $Driver -Id "sb_form_q"
        Send-SeKeys -Element $Element -Keys "the cheesecake factory"
        $button = Find-SeElement -Driver $Driver -id "sb_form_go"


        Invoke-SeClick -Element $button
        $xpath = Find-SeElement -Driver $Driver -XPath "/html/body/div[1]/main/ol/li[1]/h2/a"
        Invoke-SeClick -Element $xpath

        #$title = Find-SeElement -Driver $Driver -TagName "title"
       # $title2 = Get-SeElementAttribute -Element $fb -Attribute "title"
        #write-host "title : $title2"

        #$fb = Find-SeElement -Driver $Driver -ClassName "social-facebook"
        #$id = Find-SeElement -Driver $Driver -id "91534e67-cff5-4f89-a181-0237d2aba0b8"
        #$fb2 = Get-SeElementAttribute -Element $fb -Attribute title
        #write-host "id" $id.title
        #write-host "fb :" $fb
        #write-host "fb2 : $fb2"

        $linkText = Find-SeElement -Driver $Driver -LinkText "Contact Us"
        write-host "linkText" : $linkText



        #$linkText.Click
        #Invoke-SeClick -Element $linkText


        $Driver.title | Should Be 'Welcome to The Cheesecake Factory'
        Stop-SeDriver -Driver $Driver

        # $Driver = Start-SeChrome
        # Enter-SeUrl https://www.google.com/ -Driver $Driver
        # #$Element = Find-SeElement -Driver $Driver -Id "myControl"
        # $Driver.Navigate().GoToURL($YourURL) # Browse to the sp
        # $Driver.FindElementByName("q").SendKeys("mavericksevmont tech blog") # Methods to find the input textbox for google search and then to type something in it
        #$Driver.FindElementByName("btnK").Submit() # Method to submit request to the button


#  driver.Navigate().GoToUrl("https://www.bing.com/");

#             driver.FindElement(By.Id("sb_form_q")).SendKeys("the cheesecake factory");
#             driver.FindElement(By.Id("sb_form_go")).Click();
#             driver.FindElement(By.XPath("(.//*[normalize-space(text()) and normalize-space(.)='Region'])[1]/following::strong[1]")).Click();
#         }

#         write-host $Driver
#         Get-SeCookie $Driver
     }
    
}




# $Driver = Start-SeFirefox
# Enter-SeUrl https://www.poshud.com -Driver $Driver


# $Driver = Start-SeFirefox
# Enter-SeUrl https://www.poshud.com -Driver $Driver
# $Element = Find-SeElement -Driver $Driver -Id "myControl"


# $Driver = Start-SeFirefox
# Enter-SeUrl https://www.poshud.com -Driver $Driver
# $Element = Find-SeElement -Driver $Driver -Id "btnSend"
# Invoke-SeClick -Element $Element



# $Driver = Start-SeFirefox
# Enter-SeUrl https://www.poshud.com -Driver $Driver
# $Element = Find-SeElement -Driver $Driver -Id "txtEmail"
# Send-SeKeys -Element $Element -Keys "adam@poshtools.com"
