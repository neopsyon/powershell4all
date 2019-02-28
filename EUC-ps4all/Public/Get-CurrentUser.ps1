<#
.SYNOPSIS
Function to query current users on the system.

.DESCRIPTION
Queries local or remote computer for the users that are logged in, function accepts pipeline.

.PARAMETER ComputerName
Name of the distinguished computer that you want to execute a query against

.EXAMPLE
PS C:\> Get-ADComputer -Filter {operatingsystem -like '*server*'} | Get-CurrentUser

Hostname  Username  LogonTime            Status
--------  --------  ---------            ------
SDC-ADC01 keyholder 2/12/2019 4:39:00 PM Active
SDC-ADC01 keymaster 2/12/2019 5:35:00 PM Disc  
RDC-ADC01 keyholder 2/15/2019 2:27:00 PM Disc  
Get-CurrentUser : Connecting to remote server SDC-ACS01 failed with the following error message : Access is denied. For more information, see the about_Remote_Troubleshooting Help topic.
At line:1 char:61
+ ... Computer -Filter {operatingsystem -like '*server*'} | Get-CurrentUser
+                                                           ~~~~~~~~~~~~~~~
    + CategoryInfo          : NotSpecified: (:) [Write-Error], PSRemotingTransportException
    + FullyQualifiedErrorId : System.Management.Automation.Remoting.PSRemotingTransportException,Get-CurrentUser
WARNING: [EDC-ADC01] : Unable to connect to computer. Skipping.

.INPUTS
System.String

.OUTPUTS
PSCustomObject
#>
Function Get-CurrentUser {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    [Alias('gcu')]
    param (
        # Parameter help description
        [Parameter(ValueFromPipeline=$true,
        ValueFromPipelineByPropertyName=$true,
        Position=0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Computer','ComputerName')]
        [string[]]$Name = $env:COMPUTERNAME
    )
    process {
        foreach ($Machine in $Name) {
            Test-QuickConnect -Name $Machine
            try {
            $GetUsers = Invoke-Command -ComputerName $Machine -ScriptBlock {quser | Select-Object -skip 1} -ErrorAction Stop
            $Finallist = [System.Collections.ArrayList]::new()
            foreach ($User in $GetUsers) {
                $Username = ($User.substring(1)).split(" ")[0]
                [datetime]$LogonTime = ($User.Substring(65))
                [string]$Status = ($User.Substring(46,6).trim())
                $TempObject = [PSCustomObject]@{
                    Hostname = $Machine
                    Username = $Username
                    LogonTime = $LogonTime
                    Status = $Status
                }
                [void]$Finallist.Add($TempObject)
            }
            $Finallist
            }
            catch {
                Write-Error -Exception $PSItem.Exception -Message $PSItem.Exception.Message
                Break
            }
        }
    }
}