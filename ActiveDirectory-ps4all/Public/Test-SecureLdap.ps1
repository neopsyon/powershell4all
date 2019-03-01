<#
.SYNOPSIS
Testing LDAP over SSL.

.DESCRIPTION
Queries Domain Controller and checks if the SSL for LDAP is configured properly.

.PARAMETER All
Parameter to execute the test LDAP query against all Domain Controllers in the domain.

.PARAMETER DomainController
Parameter to execute the test LDAP query against specific Domain Controller.

.EXAMPLE
PS C:\> Test-SecureLdap -All

DomainController SecureLDAP
---------------- ----------
SDC-ADC01              True
RDC-ADC01              True

WARNING: [EDC-ADC01] : Unable to connect to computer. Skipping.

.EXAMPLE
PS C:\> Test-SecureLdap -DomainController sdc-adc01

DomainController SecureLDAP
---------------- ----------
sdc-adc01              True

.INPUTS
System.String

.OUTPUTS
PSCustomObject
#>
Function Test-SecureLdap {
    [CmdletBinding(DefaultParameterSetName='All')]
    param (
        # Parameter to check LDAPS against all Domain Controllers.
        [Parameter(ParameterSetName='All')]
        [switch]$All,
        # Name of the Domain Controller.
        [Parameter(ParameterSetName='DomainController')]
        [ValidateNotNullOrEmpty()]
        [string]$DomainController
    )
    process {
        if ($psCmdlet.ParameterSetName -eq 'All') {
            $Output = [System.Collections.ArrayList]::new()
            $DomainControllers = (Get-ADDomainController -Filter *).Name
            foreach ($DC in $DomainControllers) {
                Test-QuickConnect -Name $DC
                $TempObject = [PSCustomObject]@{
                    DomainController = $DC
                    SecureLDAP = Test-Ldaps -DC $DC
                }
                [void]$Output.Add($TempObject)
            }
            $Output
        }
        elseif ($psCmdlet.ParameterSetName -eq 'DomainController') {
            $Output = [PSCustomObject]@{
                DomainController = $DomainController
                SecureLDAP = Test-Ldaps -DC $DomainController
            }
            $Output
        }
    }
}
