Function Get-ComputerSite {
    [CmdletBinding()]
    param (
        # Name of the target computer.
        [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Computer','ComputerName')]
        [string]$Name = $env:ComputerName
    )
    process {
        try {
            $SiteName = (Invoke-Command -ComputerName $Name -ScriptBlock {
                (Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine' -Name 'Site-Name').'site-name'
            } -ErrorAction Stop)
            $FoundSite = [PSCustomObject]@{
                ComputerName = $Name
                SiteName = $SiteName
            }
            $FoundSite
        }
        catch {
            Write-Error "$_" -ErrorAction Stop
        }
    }
}