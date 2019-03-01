Function Get-Membership {
    [CmdletBinding()]
    param (
    # Parameter help description
    [Parameter(Mandatory=$true,
    Position=0)]
    [ValidateNotNullOrEmpty()]
    [alias('GroupName')]
    [string[]]$Group
    )
    process {
        foreach ($Item in $Group) {
            $CheckExistence = (Get-ADGroup -Filter "Name -eq '$Item'")
            Find-EmptyString -VariableName $CheckExistence -ErrorOut "Cannot find an group object with the name $Item in $env:USERDNSDOMAIN" -Action Continue
            $MemberList = (Get-ADGroupMember -Identity "$Item").SamAccountName
            if ($true -eq [string]::IsNullOrWhiteSpace($MemberList)) {
                Write-Warning "Group $Item is empty. Skipping."
                Continue
            }
            else {
                [PSCustomObject]@{
                    Group = $Item
                    Members = $MemberList -join ','
                }
            }
        }
    }
}