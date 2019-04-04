#Copyright (c) 2015 Serguei Kouzmine
#
#Permission is hereby granted, free of charge, to any person obtaining a copy
#of this software and associated documentation files (the "Software"), to deal
#in the Software without restriction, including without limitation the rights
#to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#copies of the Software, and to permit persons to whom the Software is
#furnished to do so, subject to the following conditions:
#
#The above copyright notice and this permission notice shall be included in
#all copies or substantial portions of the Software.
#
#THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#THE SOFTWARE.

param(
  [string]$browser = '',
  [string]$base_url = 'https://www.freelancer.com',
  [string]$username = 'psymon6ng',
  [int]$max_pages = 3,
  [string]$password,
  [string]$secret = 'moscow',
  [switch]$grid,
  [switch]$debug,
  [switch]$pause
)

if ($password -eq '' -or $password -eq $null) {
  Write-Output 'Please specify password.'
  return
}
[bool]$fullstop = [bool]$PSBoundParameters['pause'].IsPresent

$MODULE_NAME = 'SeleniumWin10.psd1'
Import-Module -Name ('{0}/{1}' -f '.',$MODULE_NAME) -Force
# load_shared_assemblies


if ([bool]$PSBoundParameters['grid'].IsPresent) {
  $selenium = launch_selenium -browser $browser -grid
  Start-Sleep -Millisecond 500
} else {
  $selenium = launch_selenium -browser $browser
}

#$selenium = New-Object OpenQA.Selenium.IE.InternetExplorerDriver
$selenium.Navigate().GoToUrl($base_url)

[OpenQA.Selenium.Interactions.Actions]$actions = New-Object OpenQA.Selenium.Interactions.Actions ($selenium)

#[string]$login_css_selector = "span[id='new-nav'] button[id='login-normal']"
[string]$login_css_selector = "/html/body/div[1]/header/div/div/div[2]/a[1]"
[object]$login_button_element = find_element -xpath $login_css_selector -selenium $selenium
#[object]$login_button_element = find_element -xpath $login_css_selector
highlight ([ref]$selenium) ([ref]$login_button_element)
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_button_element).Click().Build().Perform()

Write-Output 'Log in'

#[string]$login_div_selector = "form[id='login-form']"
[string]$login_div_selector = "//*[@id='username']"

[object]$login_div_element = find_element -xpath $login_div_selector -selenium $selenium
highlight ([ref]$selenium) ([ref]$login_div_element)

<#
Example of web elements:
1. Text box
2. Button
3. Dropdown list
4. Hyperlink
5. Check Box
6. Radio Button.
#>

#Testing SeElementAttribute
#This is my test to get the attribute from the given element
#[OpenQA.Selenium.IWebElement]$login_div_element2 = find_element -xpath $login_div_selector -selenium $selenium
#the answer is id="username" , not sure how useful that is though

#Derived from element Text box, therefore no longer an element:
$getAttribute = Get-SeElementAttribute -Element $login_div_element -Attribute "id"
write-host "Attribute id = " $getAttribute

$getAttribute = Get-SeElementAttribute -Element $login_div_element -Attribute "type"
write-host "Attribute type = " $getAttribute

$getAttribute = Get-SeElementAttribute -Element $login_div_element -Attribute "placeholder"
write-host "Attribute placeholder = " $getAttribute

#Text box element:
$elementId = find_element -id "username" -selenium $selenium
highlight ([ref]$selenium) ([ref]$elementId)

#Text box element:
$elementName = find_element -name "username" -selenium $selenium
highlight ([ref]$selenium) ([ref]$elementName)

#Text box element: there are 3 input tag_name, its picked the currently one, i.e username textbox
$elementName = find_element -tag_name "input" -selenium $selenium
highlight ([ref]$selenium) ([ref]$elementName)

#Text box element:
$elementClass = find_element -classname "large-input" -selenium $selenium
highlight ([ref]$selenium) ([ref]$elementClass)

#Hyperlink element:
$linkText = find_element -link_text "Forgot Password?" -selenium $selenium
highlight ([ref]$selenium) ([ref]$linkText)

#Hyperlink element:
$partialLinkText = find_element -partial_link_text "Forgot Pass" -selenium $selenium
highlight ([ref]$selenium) ([ref]$partialLinkText)


#Testing find_elements
$parent_div_selector = "/html/body/div[1]/main/fl-login-signup-angular/fl-login-signup-modal/div/div/div/div/fl-login/fl-login-form"
#[OpenQA.Selenium.IWebElement]$parent_element = find_element -xpath $parent_div_selector -selenium $selenium
[Object]$parent_element = find_element -xpath $parent_div_selector -selenium $selenium
#select betwen the biggest dialog and small dialog all the way to password the result is the left over?
#So the element between the big and small diaglog are "Forgot Password? (Hyperlink), Remember me (checkbox) and Log In (button)"
$betweenTheDialog = "/html/body/div[1]/main/fl-login-signup-angular/fl-login-signup-modal/div/div/div/div/fl-login/fl-login-form/div[2]/form[2]/fieldset"
$elements= find_elements -xpath $betweenTheDialog -parent $parent_element -selenium $selenium
$elements.count
$max_count = 10
$element_count = 0
$element_found = $false
$elements | ForEach-Object {
  $element_count++
  if ($element_found -or ($element_count -gt $max_count)) {
    write-host $_
  }
}

#find the closest element - didn't work!!:
$css_selector = "/html/body/div[1]/main/fl-login-signup-angular/fl-login-signup-modal/div/div/div/div/fl-login/fl-login-form/div[2]/form[1]/button"
$element = find_element -xpath $css_selector -selenium $selenium
$result = find_via_closest -ancestor_locator 'main' -target_element_locator "button[type='submit']" -element_ref ([ref]$element)

[string]$login_username_selector = "//*[@id='username']"
[string]$login_username_data = $username

[object]$login_username_element = find_element -xpath $login_username_selector -selenium $selenium
highlight ([ref]$selenium) ([ref]$login_username_element)
$login_username_element.Clear()
$login_username_element.SendKeys($login_username_data)

##password

[string]$login_password_selector = "//*[@id='password']"
[string]$login_password_data = $password
[object]$login_password_element = find_element -xpath $login_password_selector -selenium $selenium
highlight ([ref]$selenium) ([ref]$login_password_element)
$login_password_element.Clear()

$login_password_element.SendKeys($login_password_data)



#[string]$login_submit_selector = "form[name='login.form'] button[id='login-btn']"
#$$("form.user-login-form[name='LoginForm.form'] button#login_btn")
#$$("form.user-login-form[name='LoginForm.form'] button[id='login_btn']")
#$$("figure.ImgContainer.ng-star-inserted img[title='psymon6ng']")
#$$("figure.ImgContainer.ng-star-inserted img[src*='unknown.png']")
[string]$login_submit_selector = "//*[@id='login_btn']"
[object]$login_submit_element = find_element -xpath $login_submit_selector -selenium $selenium
highlight ([ref]$selenium) ([ref]$login_submit_element)
#[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$login_submit_element).Click().Build().Perform()

$login_submit_element.Click()



$wait_seconds = 10
$wait_polling_interval = 300
[OpenQA.Selenium.Support.UI.WebDriverWait]$wait = New-Object OpenQA.Selenium.Support.UI.WebDriverWait ($selenium,[System.TimeSpan]::FromSeconds($wait_seconds))
$wait.PollingInterval = $wait_polling_interval

#[string]$profile_figure_selector = "figure[id='profile-figure'][class='profile-img']"
[string]$profile_figure_selector = "/html/body/app-root/ng-component/app-navigation-abtest/app-navigation-primary/fl-bit/fl-container/fl-callout[5]/fl-callout-trigger/fl-button/button/app-user-card/fl-bit/fl-user-avatar/fl-bit/fl-bit/figure"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::XPath($profile_figure_selector)))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$profile_figure_selector)
}
[object]$profile_figure_element = find_element -xpath $profile_figure_selector -selenium $selenium

highlight ([ref]$selenium) ([ref]$profile_figure_element)
[NUnit.Framework.StringAssert]::Contains("https://www.freelancer.com/dashboard",$selenium.url)
Start-Sleep -Millisecond 1000

$selenium.Navigate().GoToUrl(('{0}/jobs/myskills/1' -f $base_url))

Write-Output '' | Out-File 'freelancer_search.txt' -Encoding 'ASCII'
1..$max_pages | ForEach-Object {
  $page_count = $_

  # $selenium.Navigate().GoToUrl(('{0}/jobs/myskills/{1}/' -f $base_url,$page_count))

  [NUnit.Framework.StringAssert]::Contains(('{0}/jobs/myskills/{1}/' -f $base_url,$page_count),$selenium.url,{})

  [string]$project_table_selector = "table[id=project_table]"
  [object]$project_table_element = find_element -css_selector $project_table_selector -selenium $selenium
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_table_element).Build().Perform()

  highlight ([ref]$selenium) ([ref]$project_table_element)



  [string]$project_selector = "tr[class='project-description']"

  $project_elements = $project_table_element.FindElements([OpenQA.Selenium.By]::CssSelector($project_selector))


  Write-Host -ForegroundColor 'Blue' ('Collecting from {0} projects on page {1}' -f $project_elements.Count,$page_count)
  $project_elements | ForEach-Object {
    $project_element = $_
    [string]$project_synopsis_selector = 'div[class="project-synopsis"]'
    $project_synopsis_element = $project_element.FindElement([OpenQA.Selenium.By]::CssSelector($project_synopsis_selector))
    $project_synopsis_text = ($project_synopsis_element.getAttribute('innerHTML') -join '')
    $project_synopsis_text = $project_synopsis_text -replace '<p>','' -replace '</p>','' -replace '<p class=".*" style=".*">','' -replace '\r?\n',' ' -replace ' +',' ' -replace '^ +',''
    Write-Host -ForegroundColor 'yellow' $project_synopsis_text
    Write-Output $project_synopsis_text | Out-File 'freelancer_search.txt' -Encoding 'ASCII' -Append

    # NOTE: next action makes browser unstable. Commented
    #  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_synopsis_element).Build().Perform()

    [string]$project_actions_selector = 'div[class="project-actions"] a'
    $project_actions_element = $project_element.FindElement([OpenQA.Selenium.By]::CssSelector($project_actions_selector))
    Write-Host -ForegroundColor 'green' $project_actions_element.getAttribute('href')
    Write-Output $project_actions_element.getAttribute('href') | Out-File 'freelancer_search.txt' -Encoding 'ASCII' -Append
  }

  # next page

  [string]$pagination_selector = "div[id='browse-projects-pagination']"
  [object]$pagination_element = find_element -css_selector $pagination_selector
  highlight ([ref]$selenium) ([ref]$pagination_element)

  [string]$project_next_page_selector = ("{0} a[id='pagination_top_next']" -f $pagination_selector)
  [object]$project_next_page_element = find_element -css_selector $project_next_page_selector -selenium $selenium
  highlight ([ref]$selenium) ([ref]$project_next_page_element)
  # $project_next_page_element
  [void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$project_next_page_element).Click().Build().Perform()


  custom_pause -fullstop $fullstop

  Start-Sleep -Millisecond 2000
}

Write-Output 'To My Projects'

[string]$primary_navigation_selector = "nav[class='primary-navigation']"
[object]$primary_navigation_element = find_element -css_selector $primary_navigation_selector -selenium $selenium
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$primary_navigation_element).Click().Build().Perform()
highlight ([ref]$selenium) ([ref]$primary_navigation_element)

Start-Sleep -Millisecond 1000

$my_projects_link_text = 'My Projects'
$my_projects_actions_element = $primary_navigation_element.FindElement([OpenQA.Selenium.By]::LinkText($my_projects_link_text))
highlight ([ref]$selenium) ([ref]$my_projects_actions_element)
Start-Sleep -Millisecond 100
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$my_projects_actions_element).Click().Build().Perform()
$my_projects_actions_element

Write-Output 'To Dashboard'
[string]$primary_navigation_selector = "nav[class='primary-navigation']"
[object]$primary_navigation_element = find_element -css_selector $primary_navigation_selector -selenium $selenium
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$primary_navigation_element).Click().Build().Perform()
$primary_navigation_element
Start-Sleep -Millisecond 1000


$dashboard_link_text = 'Dashboard'
$dashboard_actions_element = $primary_navigation_element.FindElement([OpenQA.Selenium.By]::LinkText($dashboard_link_text))
highlight ([ref]$selenium) ([ref]$dashboard_actions_element)
Start-Sleep -Millisecond 100
[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$dashboard_actions_element).Click().Build().Perform()

custom_pause -fullstop $fullstop


Write-Output 'Logging out'



Start-Sleep -Millisecond 1000
[string]$profile_figure_selector = "figure[id='profile-figure'][class='profile-img']"
try {
  [void]$wait.Until([OpenQA.Selenium.Support.UI.ExpectedConditions]::ElementExists([OpenQA.Selenium.By]::CssSelector($profile_figure_selector)))
} catch [exception]{
  Write-Debug ("Exception : {0} ...`ncss = '{1}'" -f (($_.Exception.Message) -split "`n")[0],$profile_figure_selector)
}
[object]$profile_figure_element = find_element -css_selector $profile_figure_selector -selenium $selenium

highlight ([ref]$selenium) ([ref]$profile_figure_element)

[void]$actions.MoveToElement([OpenQA.Selenium.IWebElement]$profile_figure_element).Click().Build().Perform()
# TODO - click on logut



$selenium.Navigate().GoToUrl("{0}/users/onsignout.php" -f $base_url)
Start-Sleep -Millisecond 1000
cleanup ([ref]$selenium)
