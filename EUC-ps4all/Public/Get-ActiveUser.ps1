<#
.SYNOPSIS
The function is querying local or remote computer and retrieving array object which contains

.DESCRIPTION
Long description

.PARAMETER ComputerName
Name of the distinguished computer that you want to execute a query against

.EXAMPLE
An example

.NOTES
General notes
#>
Function Get-ActiveUser {
    [CmdletBinding()]
    [OutputType([object])]
    param (
        # Parameter help description
        [Parameter(ValueFromPipeline=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerName = $env:COMPUTERNAME
    )
    process {
        try {
            $GetUsers = Invoke-Command -ComputerName $ComputerName -ScriptBlock {quser | Select-Object -skip 1} -ErrorAction Stop
            $Userlist = New-Object System.Collections.ArrayList
            foreach ($User in $GetUsers) {
                $Username = ($User.substring(1)).split(" ")[0]
                [datetime]$LogonTime = ($User.Substring(65))
                [void]$Userlist.Add($Username)
            }
            $Finallist = [PSCustomObject]@{
                Hostname = $ComputerName
                Activeuser = $Userlist -join ","
                LogonTime = $LogonTime
            }
            $Finallist
        }
        catch {
            Write-Error "$($_.Exception.Message)"
        }
    }
}