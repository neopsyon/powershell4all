<#
.SYNOPSIS
Cloning user group membership.

.DESCRIPTION
Function is cloning group membership from one user to another, once completed destination user will have same group membership as a source.

.PARAMETER SourceUser
Name of the user from where you want to copy the group membership.

.PARAMETER DestinationUser
Name of the user to where you want to copy the group membership.

.EXAMPLE
Publish-UserGroupMembership -SourceUser nemanja.jovic -DestinationUser teodora.jovic

.INPUTS
System.String
#>
Function Publish-UserGroupMembership {
    [CmdletBinding()]
    param (
        # Source user from which you want to clone group membership.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceUser,
        # Destination user to which you want to clone group membership.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationUser
    )
    process {
        $FindSource = (Get-ADUser -filter "SamAccountName -eq '$SourceUser'")
        $FindDestination = (Get-ADUser -filter "SamAccountName -eq '$DestinationUser'")
        Find-EmptyString -VariableName $FindSource -ErrorOut "Cannot find an user object that matches name $SourceUser" -Action Stop
        Find-EmptyString -VariableName $FindSource -ErrorOut "Cannot find an user object that matches name $FindDestination" -Action Stop
        $SourceUser = $($FindSource.SamAccountName)
        $DestinationUser = $($FindDestination.SamAccountName)
        $SourceGroups = (Get-ADPrincipalGroupMembership -Identity $SourceUser).Name | Sort-Object
        if ($true -eq [string]::IsNullOrWhiteSpace("$SourceGroups")) {
            Write-Warning 'User is not member of any group.' -ErrorAction Stop
        }
        $DestinationGroups = (Get-ADPrincipalGroupMembership -Identity $DestinationUser).Name | Sort-Object
        $GroupDifference = (Compare-Object -ReferenceObject $SourceGroups -DifferenceObject $DestinationGroups)
        foreach ($Group in $GroupDifference) {
            if ($($Group.SideIndicator) -eq "<=") {
                $GroupName = $($Group.InputObject)
                try {
                    Add-ADGroupMember -Identity "$GroupName" -Members "$DestinationUser" -ErrorAction Stop
                    Write-Verbose "Adding user $DestinationUser to the group $GroupName"
                }
                catch {
                    Write-Error "$_" -ErrorAction Stop
                }
            }
        }
    }
}