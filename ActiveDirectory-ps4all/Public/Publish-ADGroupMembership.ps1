Function Publish-ADGroupMembership {
    [CmdletBinding()]
    param (
        # Name of the source group
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$SourceGroup,
        # Name of the destination group
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DestinationGroup
    )
    process {
        try {
            $FindSource = (Get-ADGroup -filter "Name -eq '$SourceGroup'")
            if ($true -eq [string]::IsNullOrWhiteSpace($FindSource)) {
                Write-Error "Cannot find group with the name $SourceGroup" -ErrorAction Stop
            }
        }
        catch {
            Write-Error "$($_.Exception.Message)" -ErrorAction Stop
        }
    }
}