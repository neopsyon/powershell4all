Function Get-ADSiteDetail {
    [CmdletBinding(DefaultParameterSetName="All")]
    param (
        # Parameter to check all of the AD sites.
        [Parameter(Mandatory=$false,
        ParameterSetName="All")]
        [switch]
        $All,
        # Name of the specific AD site.
        [Parameter(Mandatory=$false,
        ParameterSetName="SiteName",
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $SiteName
    )
    process {
        if ($psCmdlet.ParameterSetName -eq "All") {
        $SiteList = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().sites
        $SiteDetails = New-Object System.Collections.ArrayList
        foreach ($Site in $SiteList) {
            $TempObject = [PSCustomObject]@{
                SiteName = $($Site.Name)
                SiteLinks = $($Site.SiteLinks.Name) -join ','
                SiteSubnets = $($Site.Subnets.Name) -join ','
            }
            $SiteDetails.Add($TempObject)
        }
        $SiteDetails | Format-Table -AutoSize -Wrap
        }
        elseif ($psCmdlet.ParameterSetName -eq "SiteName") {
            $SiteList = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().sites | Where-Object {$_.Name -eq "$SiteName"}
            $SiteDetails = New-Object System.Collections.ArrayList
            foreach ($Site in $SiteList) {
                $TempObject = [PSCustomObject]@{
                    SiteName = $($Site.Name)
                    SiteLinks = $($Site.SiteLinks.Name) -join ','
                    SiteSubnets = $($Site.Subnets.Name) -join ','
                }
                $SiteDetails.Add($TempObject)
            }
            $SiteDetails | Format-Table -AutoSize -Wrap
        }
    }
}