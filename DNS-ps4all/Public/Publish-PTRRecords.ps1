Function Publish-PTRRecords {
    [CmdletBinding()]
    param (
        # Name of the forward lookup zone.
        [Parameter(Mandatory=$true,
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [String]
        $ZoneName
    )
    process {
        try {
            [array]$FindDC = (Get-ADDomainController -filter {Domain -eq "$env:USERDNSDOMAIN"} -ErrorAction Stop).Name
            $DomainController = $FindDC[0]
            $FindTheZone = (Get-DNSServerZone -ComputerName $DomainController -Name "$ZoneName" -ErrorAction Stop).ZoneName
            $ARecords = (Get-DnsServerResourceRecord -ComputerName $DomainController -RRType A -ZoneName "$FindTheZone" | Where-Object {$_.HostName -notlike '*DNSZones*' -and $_.HostName -notlike '*@*'} `
            | Select-Object HostName,@{Name="IPAddress";Expression={$_.RecordData.IPv4Address}} -ErrorAction Stop)
            $AggregatedSubnets = New-Object System.Collections.ArrayList
            $ReversedZones = New-Object System.Collections.ArrayList
            foreach ($Record in $ARecords) {
                $FullAddress = $($Record.IPAddress.ipaddresstostring)
                $LastOctet = $($FullAddress).Split(".")[3]
                $Subnetwithdot = $($FullAddress).TrimEnd("$($LastOctet)")
                $Subnet = $Subnetwithdot.TrimEnd(".")
                [void]$AggregatedSubnets.Add($Subnet)
            }
            $AggregatedSubnets = $AggregatedSubnets | Select-Object -Unique
            foreach ($Member in $AggregatedSubnets) {
                $OctetOne = $Member.Split(".")[0]
                $OctetTwo = $Member.Split(".")[1]
                $OctetThree = $Member.Split(".")[2]
                $ReversedZone = "$($OctetThree)."+"$($OctetTwo)."+"$($OctetOne).in-addr.arpa"
                [void]$ReversedZones.Add($ReversedZone)
            }
            foreach ($PTRZone in $ReversedZones) {
                $PTRZoneCheck = (Get-DnsServerZone -ComputerName $DomainController -Name $PTRZone -ErrorAction SilentlyContinue)
                if ($true -eq [string]::IsNullOrWhiteSpace($PTRZoneCheck)) {
                    $TrimARPA = $PTRZone.TrimEnd(".in-addr.arpa")
                    $OctetOne = $TrimARPA.Split(".")[2]
                    $OctetTwo = $TrimARPA.Split(".")[1]
                    $OctetThree = $TrimARPA.Split(".")[0]
                    $NetworkID = "$($OctetOne)."+"$($OctetTwo)."+"$($OctetThree).0/24"
                    Write-Output "Creating reversed zone with network ID $NetworkID"
                    try {
                        Add-DNSServerPrimaryZone -ComputerName $DomainController -NetworkID $NetworkID -ReplicationScope Forest -ErrorAction Stop
                    }
                    catch {
                        Write-Error "$_" -ErrorAction Stop
                    }
                }
            }
            foreach ($Record in $ARecords) {
                $FullAddress = $($Record.IPAddress.ipaddresstostring)
                $OctetOne = $FullAddress.Split(".")[0]
                $OctetTwo = $FullAddress.Split(".")[1]
                $OctetThree = $FullAddress.Split(".")[2]
                $OctetFour = $FullAddress.Split(".")[3]
                $TargetZone = "$($OctetThree)."+"$($OctetTwo)."+"$($OctetOne).in-addr.arpa"
                $HostLookup = "$($Record.HostName)."+"$($ZoneName)."
                $TTL = "01:00:00"
                $FindRecord = Get-DNSServerResourceRecord -ComputerName $DomainController -ZoneName $TargetZone -RRType PTR | Where-Object {$_.RecordData.PtrDomainName -eq $HostLookup -and $_.Hostname -eq $OctetFour}
                if ($true -eq [string]::IsNullOrWhiteSpace($FindRecord)) {
                    try {
                        Write-Output "Adding PTR record for $HostLookup with address $FullAddress"
                        Add-DnsServerResourceRecordPtr -ComputerName $DomainController -ZoneName $TargetZone -Name $OctetFour -PTRDomainName $HostLookup -TimeToLive $TTL -AllowUpdateAny
                    }
                    catch {
                        Write-Error "$_" -ErrorAction Stop
                    }
                }
            }
        }
        catch {
            Write-Error "$_" -ErrorAction Stop
        }
    }
}