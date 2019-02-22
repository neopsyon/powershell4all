Function Test-SecureLdap {
    [CmdletBinding(DefaultParameterSetName="All")]
    param (
        # Parameter to check LDAPS against all Domain Controllers.
        [Parameter(ParameterSetName="All")]
        [switch]
        $All,

        # Name of the Domain Controller.
        [Parameter(ParameterSetName="DomainController")]
        [ValidateNotNullOrEmpty()]
        [string]
        $DomainController
    )
    process {
        if ($psCmdlet.ParameterSetName -eq "All") {
            $DomainControllers = (Get-ADDomainController -Filter *).Name
            $Output = foreach ($DC in $DomainControllers) {
                [PsCustomObject]@{
                    DomainController = $DC
                    SecureLDAP = Test-Ldaps -DC $DC
                }
            }
            $Output
        }
        elseif ($psCmdlet.ParameterSetName -eq "DomainController") {
            Test-Ldaps -DC $DomainController
        }
    }
}
