<#
.SYNOPSIS
Short description

.DESCRIPTION
Long description

.PARAMETER User
Parameter description

.PARAMETER Computer
Parameter description

.EXAMPLE
An example

.NOTES
General notes
#>
Function Find-ScheduledJobByUser {
    [CmdletBinding()]
    [OutPutType([PSCustomObject])]
    param (
        # Name of the user under which scheduled job is running.
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [Alias('UserName')]
        [string]$User,
        # Name of the computer that you want to query.
        [Parameter(Mandatory=$true,
        ValueFromPipelineByPropertyName=$true)]
        [Alias('ComputerName')]
        [string[]]$Computer
    )
    begin {
        $ItemList = [System.Collections.ArrayList]::new()
        $DomainAndUser = "$env:USERDOMAIN\" + $User
    }
    process {
        foreach ($Item in $Computer) {
            Test-QuickConnect -Name $Item
            $GetTask = cmd.exe /c schtasks.exe /query /s $Item /V /FO CSV | ConvertFrom-Csv | Where-Object {$_."Run As User" -eq "$DomainAndUser" -or $_."Run As User" -eq $User}
            foreach ($Task in $GetTask) {
                $TempObject = [PSCustomObject]@{
                    HostName = $($Task.HostName)
                    TaskName = $($Task.TaskName).split('\')[-1]
                    RunAs = $($Task."Run As User")
                    Author = $($Task.Author)
                }
                [void]$ItemList.Add($TempObject)
            }
            $ItemList
        }
    }
}