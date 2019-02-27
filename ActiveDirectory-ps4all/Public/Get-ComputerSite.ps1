Function Get-ComputerSite {
    [CmdletBinding()]
    param (
        # Name of the target computer.
        [Parameter(Mandatory=$true,
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]$ComputerName = $env:ComputerName
    )
    process {
        try {
            $SiteName = (Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                (Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine' -Name 'Site-Name').'site-name'
            } -ErrorAction Stop)
            $FoundSite = [PSCustomObject]@{
                ComputerName = $ComputerName
                SiteName = $SiteName
            }
            $FoundSite
        }
        catch {
            Write-Error "$_" -ErrorAction Stop
        }
    }
}