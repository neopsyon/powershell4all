<#
.SYNOPSIS
Returns the site code for the specified computer.

.DESCRIPTION
Queries the registry of a specified computer and returns value of the 'Site-Name' property found in 'HKLM:\..\Group Policy\..\Machine'.

.PARAMETER Name
Specifies the name of the distinguished computer that query is going to be executed against.

.EXAMPLE
PS C:\> Get-ADComputer -Filter "OperatingSystem -like '*Windows10*'" | Get-ComputerSite
WARNING: [PC1] : Unable to connect to computer. Skipping.

ComputerName SiteName
------------ --------
PC2          HQ
PC3          Branch1
PC4          Operations

Verfies the connectivity of each computer in $Comps, and if available, returns the site name for each.

.EXAMPLE
PS C:\> $Comps = 'PC1','PC2','PC3','PC4'
PS C:\> Get-ComputerSite -Name $Comps
WARNING: [PC1] : Unable to connect to computer. Skipping.

ComputerName SiteName
------------ --------
PC2          HQ
PC3          Branch1
PC4          Operations
Verfies the connectivity of each computer in $Comps, and if available, returns the site name for each.

.INPUTS
System.String

.OUTPUTS
PSCustomObject
#>
Function Get-ComputerSite {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    [Alias('pcsite')]
    Param (
        [Parameter(ValueFromPipeline=$true
        ,ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('ComputerName','Computer')]
        [String[]]$Name = $env:ComputerName
    )
    Process {
        ForEach ($Machine in $Name) {
            Test-QuickConnect -Name $Machine
            $SiteSplat = @{
                ComputerName= $Machine
                ScriptBlock = [ScriptBlock]::Create("Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine' -Name 'Site-Name'")
                ErrorAction = 'Stop'
            }
            Try {
                $SiteCode = Invoke-Command @SiteSplat
            } 
            Catch {
                Write-Error -Exception $PSItem.Exception -Message $PSItem.Exception.Message
                Break
            }
            [PSCustomObject]@{
            ComputerName = $Machine
            SiteCode = $SiteCode
            }
        }
    } 
}  