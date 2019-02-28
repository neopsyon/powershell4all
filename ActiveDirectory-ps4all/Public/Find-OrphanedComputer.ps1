Function Find-OrphanedComputer {
    [CmdletBinding()]
    param (
        # Password age in days.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int16]$PasswordOlderThan
    )
    process {
        $PasswordDate = (Get-Date).AddDays(-$PasswordOlderThan).ToFileTime()
        $Computerlist = (Get-ADComputer -filter {Enabled -eq $true } -Properties * | Where-Object {$_.PwdLastSet -le $PasswordDate})
        if ($true -eq [string]::IsNullOrWhiteSpace($Computerlist)) {
            Write-Output "There are not orphaned computer objects in $env:USERDNSDOMAIN"
        }
        else {
            $Orphanedlist = [System.Collections.ArrayList]::new()
            foreach ($Computer in $Computerlist) {
                $TempObject = [PSCustomObject]@{
                    ComputerName = $($Computer.Name)
                    PasswordLastSet = $($Computer.PasswordLastSet)
                }
                [void]$Orphanedlist.Add($TempObject)
            }
            $Orphanedlist
        }
    }
}