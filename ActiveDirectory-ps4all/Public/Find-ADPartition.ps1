<#
.SYNOPSIS
Find AD partition based on your choice.

.DESCRIPTION
Function that queries Active Directory objects and finds out exact name of the partition, based on user input.

.PARAMETER All
Select this parameter in order to search for all Active Directory partition names.

.PARAMETER PartitionName
Name of the partition that you want to search for.

.EXAMPLE
PS C:\Windows\system32> Find-ADPartition -All

Partition                                    
---------                                    
DC=ForestDnsZones,DC=local,DC=domain         
DC=DomainDnsZones,DC=local,DC=domain         
CN=Schema,CN=Configuration,DC=local,DC=domain
CN=Configuration,DC=local,DC=domain          
DC=local,DC=domain 

.EXAMPLE
PS C:\> Find-ADPartition -PartitionName Configuration
CN=Configuration,DC=domain,DC=local

.INPUTS
System.String

.OUTPUTS
PSCustomObject
System.String
#>
Function Find-ADPartition {
    [CmdletBinding(DefaultParameterSetName="All")]
    [OutputType([string])]
    param (
        [Parameter(ParameterSetName="All")]
        [switch]$All,
        [Parameter(ParameterSetName="PartitionName",
        ValueFromPipeline=$true,
        Position=0)]
        [ValidateSet('Root','Configuration','Schema','ForestDNS','DomainDNS')]
        [string]$PartitionName
    )
    Process {
        $Partitionlist = (Get-ADDomainController -Filter * | Select-Object -First 1).partitions
        if ($PSCmdlet.ParameterSetName -eq "All") {
            foreach ($Item in $Partitionlist) {
                [PSCustomObject]@{
                    Partition = $Item;
                }
            }
        }
        elseif ($PSCmdlet.ParameterSetName -eq "PartitionName") {
            if ($PartitionName -eq 'Root') {
                $Partitionlist | Where-Object {$_ -eq "DC=$($env:USERDNSDOMAIN.split('.')[0]),DC=$($env:USERDNSDOMAIN.split('.')[1])"}
            }
            elseif ($PartitionName -eq 'Configuration') {
                $Partitionlist | Where-Object {$_ -like "CN=Configuration,DC=$($env:USERDNSDOMAIN.split('.')[0]),DC=$($env:USERDNSDOMAIN.split('.')[1])"}
            }
            elseif ($PartitionName -eq 'Schema') {
                $Partitionlist | Where-Object {$_ -like "CN=Schema,CN=Configuration,DC=$($env:USERDNSDOMAIN.split('.')[0]),DC=$($env:USERDNSDOMAIN.split('.')[1])"}
            }
            elseif ($PartitionName -eq 'ForestDNS') {
                $Partitionlist | Where-Object {$_ -like "DC=ForestDNSZones,DC=$($env:USERDNSDOMAIN.split('.')[0]),DC=$($env:USERDNSDOMAIN.split('.')[1])"}
            }
            elseif ($PartitionName -eq 'DomainDNS') {
                $Partitionlist | Where-Object {$_ -like "DC=DomainDNSZones,DC=$($env:USERDNSDOMAIN.split('.')[0]),DC=$($env:USERDNSDOMAIN.split('.')[1])"}
            }
        }
    }
}