Function Get-DNSSuffix {
    [CmdletBinding()]
    param (
        # Name of the target computer
        [Parameter(Mandatory=$true,
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerName
    )
    process {
        try {
            $GetSuffix = (Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                (Get-DnsClientGlobalSetting).SuffixSearchList
            } -ErrorAction Stop)
            $SiteObject = [PSCustomObject]@{
                'Computer Name' = $ComputerName
                'DNS Suffix' = $GetSuffix
            }
            $SiteObject
        }
        catch {
            Write-Error -Message "$_" -ErrorAction Stop
        }
    }
}