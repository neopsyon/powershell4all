<#
.SYNOPSIS
Checking if remote computer is reachable.

.DESCRIPTION
Querying remote computer with the ping request, in case it is not responding, it will write an warning message and skip further actions against that computer.

.PARAMETER Name
Name of the computer that you want to query.

.EXAMPLE
Test-NetConnect -Name ComputerName
WARNING: [test1] : Unable to connect to computer. Skipping.

.INPUTS
System.String

.OUTPUTS
System.String
#>
Function Test-QuickConnect {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Computer','ComputerName')]
        [string]$Name
    )
    process {
        if ($false -eq (Test-Connection -ComputerName $Name -Count 1 -Quiet)) {
            Write-Warning ('[{0}] : Unable to connect to computer. Skipping.' -F $Name)
            Continue
        }
    }
}