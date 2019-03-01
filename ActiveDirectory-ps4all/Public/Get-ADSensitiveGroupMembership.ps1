<#
.SYNOPSIS
Getting the membership of the group.

.DESCRIPTION
Queries the membership list of one of the Active Directory sensitive groups.

.PARAMETER All
Parameter to query all sensitive groups.

.PARAMETER GroupName
Parameter to query specific group.

.EXAMPLE
An example

.NOTES
General notes
#>

Function Get-ADSensitiveGroupMembership {
    [CmdletBinding(DefaultParameterSetName='All')]
    param (
        # Parameter to get membership of all sensitive AD groups.
        [Parameter(Mandatory=$false,
        ParameterSetName='All')]
        [switch]$All,
        # Parameter help description
        [Parameter(Mandatory=$false,
        ParameterSetName='GroupName')]
        [ValidateSet('Administrators','Domain Admins','Enterprise Admins','Schema Admins')]
        [string]$GroupName
    )
    process {
        $GroupList = @('Administrators','Domain Admins','Enterprise Admins','Schema Admins')
        if ($PSCmdlet.ParameterSetName -eq 'All') {
            foreach ($Group in $GroupList) {
                Get-Membership -Group $Group
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq 'GroupName') {
            foreach ($Group in $GroupList) {
                if ($GroupName -eq $Group) {
                    Get-Membership -Group $GroupName
                }
            }
        }
    }
}