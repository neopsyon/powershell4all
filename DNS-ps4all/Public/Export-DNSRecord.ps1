Function Export-DNSRecord {
        [CmdletBinding()]
        param (
            # Parameter help description
            [Parameter()]
            [ValidateNotNullOrEmpty()]
            [switch]$All,
            # Parameter help description
            [Parameter()]
            [ValidateSet('A','AAA','PTR','CNAME')]
            [Alias('Type')]
            [switch]$RRType,
            # Parameter help description
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Alias('ZoneName')]
            [string]$Zone
        )
        begin {
            [array]$DC = (Get-ADDomainController -Filter *).Name
            try {
                (Get-DNSServerZone -ComputerName $DC[0] -Name $Zone -ErrorAction Stop)
            }
            catch {
                Write-Error "$_" -ErrorAction Stop
            }
        }
        process {
            
        }
}