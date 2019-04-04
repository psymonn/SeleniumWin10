echo off
set arg1=%1
set arg2=%2
shift
shift
rem fake-command /u %arg1% /p %arg2% %*
rem java -jar C:\Data\Git\Selenium\lib40\selenium-server-standalone-3.141.59.jar -role hub -host 127.0.0.1
echo java -jar C:\Data\Git\Selenium\lib40\selenium-server-standalone-3.141.59.jar -role hub -host %arg1% -port %arg2%
java -jar C:\Data\Git\Selenium\lib40\selenium-server-standalone-3.141.59.jar -role hub -host %arg1% -port %arg2%

