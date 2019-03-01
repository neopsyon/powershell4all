<#
.SYNOPSIS
Find AD partition based on your choice.

.DESCRIPTION
Function that queries Active Directory objects and finds out exact name of the partition, based on user input.

.PARAMETER PartitionName
Name of the partition that you want to search for.

.EXAMPLE
PS C:\> Find-ADPartition -PartitionName Configuration
CN=Configuration,DC=domain,DC=local

.INPUTS
System.String

.OUTPUTS
System.String
#>
Function Find-ADPartition {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        # Name of the partition that you want to find.
        [Parameter(Mandatory=$true,
        ValueFromPipeline=$true,
        Position=0)]
        [ValidateSet('Root','Configuration','Schema','ForestDNS','DomainDNS')]
        [string]$PartitionName
    )
    Process {
        $Partitionlist = (Get-ADDomainController -Filter * | Select-Object -First 1).partitions
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