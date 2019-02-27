<#
    .SYNOPSIS
        Returns the site code for the specified computer.
    .DESCRIPTION
        Queries the registry of a specified computer and returns value of the 'Site-Name' property found in 'HKLM:\..\Group Policy\..\Machine'.
    .EXAMPLE
        PS C:\> $Comps = 'PC1','PC2','PC3','PC4' | ForEach-Object {Get-ADComputer -Identity $PSItem}
        PS C:\> $Comps | Get-ComputerSite
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
    [Alias('pcsite')]
    Param (
        [Parameter(ValueFromPipelineByPropertyName, Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('ComputerName')]
            [String[]]$Name = $env:ComputerName
    )
    
    Process {
        ForEach ($Machine in $Name) {
            If (!(Test-Connection -ComputerName $Machine -Count 1 -Quiet)) {
                Write-Warning ('[{0}] : Unable to connect to computer. Skipping.' -F $Machine)
            } Else {
                $SiteSplat = @{
                    ComputerName= $Machine
                    ScriptBlock = [ScriptBlock]::Create("Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine' -Name 'Site-Name'")
                    ErrorAction = 'Stop'
                }
                
                Try {
                    $SiteCode = Invoke-Command @SiteSplat
                } Catch {
                    Write-Error -Exception $PSItem.Exception -Message $PSItem.Exception.Message
                    Break
                }

                [PSCustomObject]@{
                    ComputerName= $Machine
                    SiteCode    = $SiteCode
                }
            } # Connectivity Check
        } # ForEach Machine in Name
    } # Process Block
} # Function Get-ComputerSite
