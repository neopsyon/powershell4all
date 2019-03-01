Function Export-DNSRecord {
        [CmdletBinding()]
        param (
            [Parameter(ParameterSetName="All")]
            [ValidateNotNullOrEmpty()]
            [switch]$All,
            #
            [Parameter(ParameterSetName="Single")]
            [ValidateSet('A','AAA','PTR','CNAME')]
            [Alias('Type')]
            [string]$RRType,
            #
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [Alias('ZoneName')]
            [string]$Zone,
            #
            [Parameter(Mandatory=$true)]
            [ValidateNotNullOrEmpty()]
            [string]$Path
        )
        begin {
            [array]$DC = (Get-ADDomainController -Filter *).Name
            try {
                [void](Get-DNSServerZone -ComputerName $DC[0] -Name $Zone -ErrorAction Stop)
            }
            catch {
                Write-Error "$_" -ErrorAction Stop
            }
        }
        process {
            if ($PSCmdlet.ParameterSetName -eq "All") {

            }
            elseif ($PSCmdlet.ParameterSetName -eq "Single") {

            }
        }
}