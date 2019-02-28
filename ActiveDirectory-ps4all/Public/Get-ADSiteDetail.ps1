Function Get-ADSiteDetail {
    [CmdletBinding(DefaultParameterSetName='All')]
    param (
        # Parameter to check all of the AD sites.
        [Parameter(ParameterSetName='All')]
        [switch]$All,
        # Name of the specific AD site.
        [Parameter(ParameterSetName='SiteName',
        ValueFromPipelineByPropertyName=$true,
        Position=1)]
        [Alias('Site','Name')]
        [ValidateNotNullOrEmpty()]
        [string]$SiteName
    )
    process {
        if ($psCmdlet.ParameterSetName -eq 'All') {
        $SiteList = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().sites
        $SiteDetails = [System.Collections.ArrayList]::new()
        foreach ($Site in $SiteList) {
            $TempObject = [PSCustomObject]@{
                SiteName = $($Site.Name)
                SiteLinks = $($Site.SiteLinks.Name) -join ','
                SiteSubnets = $($Site.Subnets.Name) -join ','
            }
            [void]$SiteDetails.Add($TempObject)
        }
        $SiteDetails | Format-Table -AutoSize -Wrap
        }
        elseif ($psCmdlet.ParameterSetName -eq 'SiteName') {
            $SiteList = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().sites | Where-Object {$_.Name -eq "$SiteName"}
            $SiteDetails = [System.Collections.ArrayList]::new()
            foreach ($Site in $SiteList) {
                $TempObject = [PSCustomObject]@{
                    SiteName = $($Site.Name)
                    SiteLinks = $($Site.SiteLinks.Name) -join ','
                    SiteSubnets = $($Site.Subnets.Name) -join ','
                }
                [void]$SiteDetails.Add($TempObject)
            }
            $SiteDetails | Format-Table -AutoSize -Wrap
        }
    }
}