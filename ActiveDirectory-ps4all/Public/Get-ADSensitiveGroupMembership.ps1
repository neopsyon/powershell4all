<#
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
        Function Get-Membership {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory=$true,
                Position=1)]
                [ValidateNotNullOrEmpty()]
                [string]
                $Group
            )
            process {
                $GroupMembers = [System.Collections.ArrayList]::new()
                $CheckExistence = (Get-ADGroup -Filter "Name -eq '$Group'")
                Find-EmptyString -VariableName $CheckExistence -ErrorOut "Cannot find an group object with the name $Group in $env:USERDNSDOMAIN" -Action Continue
                if ($false -eq [string]::IsNullOrWhiteSpace($CheckExistence)) {
                    $Members = (Get-ADGroupMember -Identity "$Group").SamAccountName
                     if ($false -eq [string]::IsNullOrWhiteSpace($Member)) {
                         $TempObject = [PSCustomObject]@{
                             GroupName = $Group
                             Members = $Members -join ','
                         }
                         [void]$GroupMembers.Add($TempObject)
                     }
                }
                $GroupMembers
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'All') {
            $Groupedobjects = [System.Collections.ArrayList]::new()
            foreach ($Group in $GroupList) {
                $Getit = Get-Membership -Group $Group
                [void]$Groupedobjects.Add($Getit)
            }
            $Groupedobjects
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