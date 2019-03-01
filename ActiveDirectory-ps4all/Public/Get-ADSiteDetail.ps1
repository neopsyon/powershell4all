<#
.SYNOPSIS
Getting details of Active Directory site.

.DESCRIPTION
Function is querying Active Directory site and putting certain properties into custom object which is afterwards outputed on the screen.

.PARAMETER All
Parameter to search against all Active Directory sites.

.PARAMETER SiteName
Parameter to search against specific Active Directory site.

.EXAMPLE
PS C:\> Get-ADSiteDetail -All

SiteName                SiteLinks                               SiteSubnets                                             
--------                ---------                               -----------                                             
Default-First-Site-Name                                                                                                 
Amsterdam               Amsterdam-NewYork,Amsterdam-Jordan  10.10.10.0/24,10.10.5.0/24,10.30.12.0/24,192.168.2.0/24 
NewYork                 Amsterdam-NewYork,NewYork-Jordan 10.40.11.0/24,10.200.4.0/24,10.20.10.0/24,192.168.0.0/24
Jordan                 Amsterdam-Jordan,NewYork-Jordan    10.70.10.0/24 

.EXAMPLE
PS C:\> Get-ADSiteDetail -SiteName Amsterdam

SiteName  SiteLinks                              SiteSubnets                                            
--------  ---------                              -----------                                            
Amsterdam Amsterdam-NewYork,Amsterdam-Jordan 10.10.10.0/24,10.10.5.0/24,10.30.12.0/24,192.168.2.0/24

.INPUTS
System.String

.OUTPUTS
PSCustomObject
#>
Function Get-ADSiteDetail {
    [CmdletBinding(DefaultParameterSetName='All')]
    [OutputType([pscustomobject])]
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