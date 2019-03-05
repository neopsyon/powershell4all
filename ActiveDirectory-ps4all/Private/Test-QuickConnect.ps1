<#
.SYNOPSIS
Checking if remote computer is reachable.

.DESCRIPTION
Querying remote computer with the fast ping request, in case it is not responding, it will write an warning message and skip further actions against that computer.

.PARAMETER Name
Name of the computer that you want to query.

.PARAMETER Count
Number of pings that you want to perform.

.PARAMETER Delay
Number of miliseconds that you want to pause between ping requests.

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
        [string]$Name,
        [int]$Count = 2,
        [int]$Delay = 100
    )
    process {
        for ($I = 1; $I -lt $Count + 1 ; $i++) {
            If (Test-Connection -ComputerName $Name -Quiet -Count 1) {
                return $True
            }
            Start-Sleep -Milliseconds $Delay
        }
        Write-Warning ("[$Name] : Unable to connect to computer. Skipping.")
        Continue
    }
}