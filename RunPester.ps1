[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]$browser,
    [String]$source,
    [String]$outFile
 )
 
 Try {
 
     Write-verbose "Executing Pester tests"
                          
     Invoke-Pester -verbose -OutputFile $outFile -OutputFormat NUnitXml -EnableExit -Script @{ Path = $source; Parameters = @{browser = $browser;};}
        
 }
 Catch {
    Exit 1
 }
 