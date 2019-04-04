## unrelated...just for my info: get-variable
## New-ScriptVariable.ps1
#https://www.leeholmes.com/blog/2009/03/26/more-tied-variables-in-powershell/
#https://stackoverflow.com/questions/4580740/creating-powershell-automatic-variables-from-c-sharp
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_scopes?view=powershell-6
param($name, [ScriptBlock] $getter, [ScriptBlock] $setter)

Add-Type @"
using System;
using System.Collections.ObjectModel;
using System.Management.Automation;

namespace Lee.Holmes
{
    public class PSScriptVariable : PSVariable
    {
        public PSScriptVariable(string name, ScriptBlock scriptGetter, ScriptBlock scriptSetter) : base(name, null, ScopedItemOptions.AllScope)
        {
            getter = scriptGetter;
            setter = scriptSetter;
        }
        private ScriptBlock getter;
        private ScriptBlock setter;

        public override object Value
        {
            get
            {
                if(getter != null)
                {
                    Collection<PSObject> results = getter.Invoke();
                    if(results.Count == 1)
                    {
                        return results[0];
                    }
                    else
                    {
                        PSObject[] returnResults = new PSObject[results.Count];
                        results.CopyTo(returnResults, 0);
                        return returnResults;
                    }
                }
                else { return null; }
            }
            set
            {
                if(setter != null) { setter.Invoke(value); }
            }
        }
    }
}
"@

if(Test-Path variable:\$name)
{
    Remove-Item variable:\$name -Force
}
$executioncontext.SessionState.PSVariable.Set((New-Object Lee.Holmes.PSScriptVariable $name,$getter,$setter))

<# usage:

    PS C:\temp> cd \temp
    PS C:\temp> New-ScriptVariable.ps1 GLOBAL:lee { $myTestVariable } { $GLOBAL:myTestVariable = 2 * $args[0] }
    PS C:\temp> $lee
    PS C:\temp> $lee = 10
    PS C:\temp> $lee
    20
    PS C:\temp> New-ScriptVariable.ps1 GLOBAL:today { (Get-Date).DayOfWeek }
    PS C:\temp> $today
    Wednesday
    PS C:\temp> New-ScriptVariable.ps1 GLOBAL:random -Get { Get-Random } -Set { Get-Random -SetSeed $args[0] }
    PS C:\temp> $random
    1740776676
    PS C:\temp> $random
    1507521897
    PS C:\temp> $random = 10
    PS C:\temp> $random
    1613858733
    PS C:\temp> $random = 10
    PS C:\temp> $random
    1613858733

#>
