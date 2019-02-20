Function Publish-UserGroupMembership {
    [CmdletBinding()]
    param (
        # Source user from which you want to clone group membership.
        [Parameter(Mandatory=$true,
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SourceUser,
        # Destination user to which you want to clone group membership.
        [Parameter(Mandatory=$true,
        Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]
        $DestinationUser
    )
    process {
        $FindSource = (Get-ADUser -filter * | Where-Object {$_.SamAccountName -eq "$SourceUser"})
        $FindDestination = (Get-ADUser -filter * | Where-Object {$_.SamAccountName -eq "$DestinationUser"})
        Find-EmptyString -VariableName $FindSource -ErrorOut "Cannot find an user object that matches name $SourceUser" -Action Stop
        Find-EmptyString -VariableName $FindSource -ErrorOut "Cannot find an user object that matches name $FindDestination" -Action Stop
        $SourceGroups = (Get-ADPrincipalGroupMembership -Identity $($FindSource.SamAccountName)).Name | Sort-Object
        if ($true -eq [string]::IsNullOrWhiteSpace("$SourceGroups")) {
            Write-Output "User is not member of any group." -ErrorAction Stop
        }
        $DestinationGroups = (Get-ADPrincipalGroupMembership -Identity $($FindDestination.SamAccountName)).Name | Sort-Object
        $GroupDifference = (Compare-Object -ReferenceObject $SourceGroups -DifferenceObject $DestinationGroups).inputobject
        foreach ($Group in $GroupDifference) {
            try {
                Add-ADGroupMember -Identity "$Group" -Members $($FindDestination.SamAccountName)
            }
            catch {
                Write-Error "$_" -ErrorAction Continue
            }
        }
    }
}