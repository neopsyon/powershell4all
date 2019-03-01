<#
.SYNOPSIS
Transfering copy of members from one to another group. 

.DESCRIPTION
Function which is cloning members from one to another Active Directory group.

.PARAMETER SourceGroup
Name of the group from where you want to copy the members.

.PARAMETER DestinationGroup
Name of the destination group to where you want to copy the members.

.EXAMPLE
Publish-ADGroupMembership -SourceGroup Group1 -DestinationGroup Group2

.INPUTS
System.String
System.Array
#>
Function Publish-ADGroupMembership {
    [CmdletBinding()]
    param (
        # Name of the source group
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$SourceGroup,
        # Name of the destination group
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [array]$DestinationGroup
    )
    process {
        try {
            foreach ($Group in @($SourceGroup + $DestinationGroup)) {
                $FindGroup = (Get-ADGroup -Filter "Name -eq '$Group'")
                Find-EmptyString -VariableName $FindGroup -ErrorOut "Cannot find an group object matching the name $Group" -Action Stop
            }
            $SourceMember = (Get-ADGroupMember -Identity "$([string]$SourceGroup)").Name
            $DestinationMember = (Get-ADGroupMember -Identity "$([string]$DestinationGroup)").Name
            $Delta = (Compare-Object -ReferenceObject $SourceMember -DifferenceObject $DestinationMember)
            foreach ($Item in $Delta) {
                if ($($Item.SideIndicator) -eq "<=") {
                    $User = $($Item.InputObject)
                    Add-ADGroupMember -Identity "$([string]$DestinationGroup)" -Members $User -ErrorAction Stop
                    Write-Verbose "Adding member - $User to the group $DestinationGroup"
                }
            }
        } 
        catch {
            Write-Error "$($_.Exception.Message)" -ErrorAction Stop
        }
    }
}