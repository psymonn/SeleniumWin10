echo off
set arg1=%1
set arg2=%2
shift
shift
rem fake-command /u %arg1% /p %arg2% %*
rem java -jar C:\Data\Git\Selenium\lib40\selenium-server-standalone-3.141.59.jar -role node -hub http://127.0.0.1:4444/grid/register/
echo java -jar C:\Data\Git\Selenium\lib40\selenium-server-standalone-3.141.59.jar -role node -hub http://%arg1%:%arg2%/grid/register/
java -jar C:\Data\Git\Selenium\lib40\selenium-server-standalone-3.141.59.jar -role node -hub http://%arg1%:%arg2%/grid/register/

