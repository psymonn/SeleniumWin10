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
