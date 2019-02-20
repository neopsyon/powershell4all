Function Invoke-ADReplication {
    [CmdletBinding(DefaultParameterSetName="All")]
    param (
        # Parameter to invoke replication against all Domain Controllers.
        [Parameter(Mandatory=$false,
        ParameterSetName="All")]
        [switch]
        $All,
        # Name of the specific Domain Controller.
        [Parameter(Mandatory=$false,
        ParameterSetName="DomainController",
        Position=1)]
        [string[]]
        $DomainController
    )
    process {
        if ($PSCmdlet.ParameterSetName -eq "All") {
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
                Write-Error "$_"
            }
        }
    }
        elseif ($PSCmdlet.ParameterSetName -eq "DomainController") {
            $FindDomainController = (Get-ADDomainController -filter * | Where-Object {$_.Name -eq "$DomainController"}).Name
            Find-EmptyString -VariableName $FindDomainController -ErrorOut "Cannot an find Domain Controller object that matches name $DomainController" -Action Stop
            $LastRepTime = (Get-ADReplicationUpToDatenessVectorTable -Target $FindDomainController).LastReplicationSuccess[0]
            Write-Output "Last replication time was at - $LastRepTime"
            try {
                Write-Output "Invoking replication against $FindDomainController"
                [void](Invoke-Command -ComputerName $FindDomainController -ScriptBlock {
                    cmd.exe /c repadmin /syncall /A /d /e /P
                } -InDisconnectedSession -ErrorAction Stop)
            }
            catch {
                Write-Error "$_"
            }
        }    
    }
}