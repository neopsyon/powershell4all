Function Test-SecureLDAP {
    [CmdletBinding(DefaultParameterSetName="All")]
    param (
        # Parameter to check LDAPS against all Domain Controllers.
        [Parameter(Mandatory=$false,
        ParameterSetName="All")]
        [switch]
        $All,
        # Name of the Domain Controller.
        [Parameter(Mandatory=$false,
        ParameterSetName="DomainController",
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DomainController
    )
    process {
        Import-RequiredModule -ModuleName ActiveDirectory
        Function Test-LDAPS {
            param (
                [parameter(Mandatory=$true)]
                [string]
                $DC
            )
            process {
                $LDAPS = [ADSI]"LDAP://$($DC):636"
                try {
                    $LDAPS = [ADSI]"LDAP://$($DC):636"
                    $Connection = [adsi]$LDAPS
                }
                catch {
                }
                if ($Connection.Path) {
                    Write-Host "LDAPS is properly configured on $DC" -ForegroundColor Green
                }
                else {
                    Write-Error -Message "Cannot establish LDAPS connection to $DC" -ErrorAction Stop
                }
            }
        }
        if ($psCmdlet.ParameterSetName -eq "All") {
            [array]$DomainControllers = (Get-ADDomainController -Filter *).Name
            foreach ($DC in $DomainControllers) {
                Test-LDAPS -DC $DC
            }
        }
        elseif ($psCmdlet.ParameterSetName -eq "DomainController") {
            Test-LDAPS -DC $DomainController
        }
    }
}