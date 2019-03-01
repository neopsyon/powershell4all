<#
.SYNOPSIS
Invokes replication against domain controller.

.DESCRIPTION
Invokes replication of all Active Directory partitions, against specific Domain Controller, or all Domain Controllers found in the domain.

.PARAMETER All
Parameter to search and invoke replication against all Domain Controllers.

.PARAMETER DomainController
Parameter to search and invoke replicaiton against specific Domain Controller.

.EXAMPLE
Invoke-ADReplication -All

.EXAMPLE
Invoke-ADReplication -DomainController AD-DC01

.INPUTS
System.String
#>
Function Invoke-ADReplication {
    [CmdletBinding(DefaultParameterSetName='All')]
    param (
        # Parameter to invoke replication against all Domain Controllers.
        [Parameter(ParameterSetName='All')]
        [switch]$All,
        # Name of the specific Domain Controller.
        [Parameter(ParameterSetName='DomainController',
        Position=0)]
        [string]$DomainController
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq 'All') {
        $DomainControllers = (Get-ADDomainController -filter *).name
        $LastRepTime = (Get-ADReplicationUpToDatenessVectorTable -Target $DomainControllers[0]).LastReplicationSuccess[0]
        Write-Output "Last replication time was at - $LastRepTime"
        foreach ($DC in $DomainControllers) {
            try {
                Write-Output "Invoking replication against $DC"
                [void](Invoke-Command -ComputerName $DC -ScriptBlock {
                    cmd.exe /c repadmin /syncall /A /d /e /P
                } -InDisconnectedSession -ErrorAction Stop)
            }
            catch {
                Write-Error -Exception $PSItem.Exception -Message $PSItem.Exception.Message
                Break
            }
        }
    }
        elseif ($PSCmdlet.ParameterSetName -eq 'DomainController') {
            $FindDomainController = (Get-ADDomainController -filter * | Where-Object {$_.Name -eq $DomainController}).Name
            Find-EmptyString -VariableName $FindDomainController -ErrorOut "Cannot an find Domain Controller object that matches name $($DomainController)" -Action Stop
            $LastRepTime = (Get-ADReplicationUpToDatenessVectorTable -Target $FindDomainController).LastReplicationSuccess[0]
            Write-Output "Last replication time was at - $LastRepTime"
            try {
                Write-Output "Invoking replication against $FindDomainController"
                [void](Invoke-Command -ComputerName $FindDomainController -ScriptBlock {
                    cmd.exe /c repadmin /syncall /A /d /e /P
                } -InDisconnectedSession -ErrorAction Stop)
            }
            catch {
                Write-Error -Exception $PSItem.Exception -Message $PSItem.Exception.Message
            }
        }    
    }
}