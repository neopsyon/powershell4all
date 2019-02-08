<#

.DESCRIPTION
Powershell4All automation tool represents an open source collaboration project with the goal to speed up the day-to-day administration tasks in Microsoft environments.
In the essence, it is just a bundle of functions that will be executed based on user input choice.

#>
Clear-host
Write-Host -ForegroundColor Green "WELCOME Powershell4all, ease of administration is in front of you!"
Write-Host -ForegroundColor Green "You can pick one of the listed options below, backend functions will do the rest for you."
Write-Host -ForegroundColor Cyan "


1. Invoke replication against all of the domain controllers in the forest.
2. Invoke DNS replication.
3. Clear DNS cache.
4. Check group membership.
5. Find inactive computers.
6. List sites and site subnets.
7. Clone user group membership from one to another user.
8. Get computer site.
9. Test secure LDAP.
10. Get local administrators.
11. Search all DHCP servers for a particular MAC address lease.
"
#############
Try {
    [int]$Number = (Read-Host -Prompt "Chose the task by entering the task number" -ErrorAction Stop)
}
Catch {
    Write-Host "Input accepts only integers, please relaunch the script." -ForegroundColor Red
    Break
}
Function Find-Module {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$True,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$ModuleName
    )
    Process {
        Try {
            import-module -Name $ModuleName -ErrorAction Stop
        }
        Catch {
            $localname = (hostname)
            Write-Host "Required module - $($ModuleName) is not installed on $($localname)" -ForegroundColor Red
            Break
        }
    }
}
Function Get-UserInput {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$WriteOut
    )
    process {
        Write-Host "$WriteOut  " -ForegroundColor Magenta -NoNewline
        Read-Host
    }
}
Function Find-EmptyString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,Position=0)]
        [AllowEmptyString()]
        [string]$VariableName
    )
    process {
        $Stringtest = [string]::IsNullOrEmpty($VariableName)
        if ($true -eq $Stringtest) {
            Write-Host "You did not insert any input." -ForegroundColor Red
            Break
        }
    }
}
function Get-UserVariable ($Name = '*')
{
  $special = 'ps','psise','psunsupportedconsoleapplications', 'foreach', 'profile'
  $ps = [PowerShell]::Create()
  $null = $ps.AddScript('$null=$host;Get-Variable') 
  $reserved = $ps.Invoke() | 
    Select-Object -ExpandProperty Name
  $ps.Runspace.Close()
  $ps.Dispose()
  Get-Variable -Scope Global | 
    Where-Object Name -like $Name |
    Where-Object { $reserved -notcontains $_.Name } |
    Where-Object { $special -notcontains $_.Name } |
    Where-Object Name 
}
Function Clear-UserVars {
    $UserVariables = Get-UserVariable
    foreach ($Var in $UserVariables) {
        Remove-Variable $Var.name -Force -Confirm:$false -Scope Global -ErrorAction SilentlyContinue
    }
}
Switch ($Number) {
    1 {
        Find-Module "ActiveDirectory"
        # Check last replication time first
        $DomainControllers = (Get-ADDomainController -filter *).name
        $LastRepTime = (Get-ADReplicationUpToDatenessVectorTable -Target $DomainControllers[0]).LastReplicationSuccess[0]
        Write-Host "Last replication time was at - $LastRepTime" -ForegroundColor Cyan
        Write-Host "Invoking replication against:" -ForegroundColor Green
        foreach ($DC in $DomainControllers) {
            Write-Host $DC -ForegroundColor Green
        }
        foreach ($DC in $DomainControllers) {
            Invoke-Command -ComputerName $DC -ScriptBlock {
                cmd.exe /c repadmin /syncall /A /e /d
            } -InDisconnectedSession | Out-Null
        }
    }
    2 {
        Find-Module ActiveDirectory
        $DClist = new-object System.Collections.Arraylist
        $SiteList = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().sites.name
        foreach ($Site in $SiteList) {
            [array]$DC = (Get-ADDomainController -Filter {Site -eq "$Site"}).name | Select-Object -First 1
            $DClist += $DC
        }
        $ZoneList = (Get-DnsServerZone -ComputerName $DClist[0] | Where-Object {$_.IsDsIntegrated -eq $true -and $_.IsReverseLookupZone -eq $false -and $_.ZoneName -notmatch "TrustAnchors" -and $_.ZoneName -notmatch "_msdcs.$($env:USERDNSDOMAIN)"}).ZoneName
        Write-Host "Invoking replication against $DClist for zones:" -ForegroundColor Green
        foreach ($zone in $ZoneList) {
            Write-Host $zone -ForegroundColor Green
        }
        foreach ($DC in $DClist) {
            foreach ($Zone in $ZoneList) {
                Invoke-Command -ComputerName $DC -ScriptBlock {
                    dnscmd /ZoneRefresh $Zone
                    Sync-DnsServerZone -Name $Zone 
                } -InDisconnectedSession | Out-Null
            }
        }
    }
    3 {
        Find-Module ActiveDirectory
        Find-Module DNSServer
        $DNSServers = (Get-UserInput -WriteOut "Type the name of DNS server, or type all to affect them all:")
        Find-EmptyString -VariableName $DNSServers
        if ($DNSServers -eq "All") {
            $DNSServers = New-Object System.Collections.ArrayList
            $FinalDNS = New-Object System.Collections.ArrayList
            [string]$DC = ([system.directoryservices.activedirectory.Forest]::GetCurrentForest().schemaroleowner.name)
            $Zonelist = (Get-DnsServerZone -ComputerName $DC | Where-Object {$_.IsDsIntegrated -eq $true -and $_.IsReverseLookupZone -eq $false -and $_.ZoneName -notmatch "TrustAnchors" -and $_.ZoneName -notmatch "_msdcs.$($env:USERDNSDOMAIN)"}).ZoneName
            foreach ($Zone in $Zonelist) {
                $DNSTemp = ((Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $Zone -RRType Ns).RecordData.NameServer | Select-Object -Unique)
                $DNSServers += $DNSTemp
            }
            foreach ($Server in $DNSServers) {
                $Name = $Server.split(".")[0]
                $FinalDNS += $Name
                }
            $FinalDNS = ($FinalDNS | Select-Object -Unique)
            foreach ($Server in $FinalDNS) {
                Try {
                    Write-Host "Clearing DNS cache on - $Server." -ForegroundColor Green
                    Invoke-Command -ComputerName $Server -ScriptBlock {
                        dnscmd /clearcache ; ipconfig /flushdns
                    } -ErrorAction Stop | Out-Null
                }
                Catch {
                    Write-Host "Cannot reach server - $Server." -ForegroundColor Red
                }
            }
        }
        else {
            $DC = ([system.directoryservices.activedirectory.Forest]::GetCurrentForest().namingroleowner.DomainControllerName)
            $Zonelist = (Get-DnsServerZone -ComputerName $DC | Where-Object {$_.IsDsIntegrated -eq $true -and $_.IsReverseLookupZone -eq $false -and $_.ZoneName -notmatch "TrustAnchors" -and $_.ZoneName -notmatch "_msdcs.$($env:USERDNSDOMAIN)"}).ZoneName
            $CheckEmpty = $null
            foreach ($Zone in $ZoneList){
                    $TestDNS = ((Get-DnsServerResourceRecord -ComputerName $DC -ZoneName $Zone -RRType Ns | Where-Object {$_.RecordData.NameServer -eq "$DNSServers.$env:USERDNSDOMAIN."}))
                    if ($null -eq $TestDNS) {
                        continue
                    }
                    else {
                        $CheckEmpty += "FoundSomething."
                    }
            }
            if ($null -eq $CheckEmpty) {
                Write-Host "DNS Server not found as authoritative for any AD integrated zone." -ForegroundColor Red
                Clear-UserVars
                Break
            }
            else {
                Try {
                    Write-Host "Clearing DNS cache on - $DNSServers." -ForegroundColor Green
                    Invoke-Command -ComputerName $DNSServers -ScriptBlock {
                        dnscmd /clearcache ; ipconfig /flushdns
                    } -ErrorAction Stop | Out-Null
                }
                Catch {
                    Write-Host "Cannot reach server - $DNSServers." -ForegroundColor Red
                }
            }
        }
    }
    4 {
        Find-Module ActiveDirectory
        $GroupName = (Get-UserInput -WriteOut "Enter the group name:")
        Find-EmptyString -VariableName $GroupName
        try {
            Get-ADGroup -Identity "$GroupName" -ErrorAction Stop | out-null
        }
        catch {
            Write-Host "Cannot find an object with identity $($GroupName) under $env:USERDNSDOMAIN" -ForegroundColor Red
            Clear-UserVars
            Break
        }
        [array]$Members = (Get-ADGroupMember -Identity "$($GroupName)").Name
        Write-Output ""
        Write-Host "Members of the group - $GroupName are:" -ForegroundColor Cyan
        foreach ($Member in $Members) {
            Write-Host "$Member" -ForegroundColor Green
        }
    }
    5 {
        Find-Module ActiveDirectory
        Write-Host "Script is going to check for all of the computer objects that did not update their password for +90 days." -ForegroundColor Cyan
        $PwdAge = 90
        $PwdDate = (get-date).AddDays(-$PwdAge).ToFileTime()
        $ComputerList = (Get-ADComputer -filter {Enabled -eq $true} -Properties * | Where-Object {$_.PwdLastSet -le $PwdDate}).Name
        $Isitempty = [string]::IsNullOrEmpty("$ComputerList")
        if ($true -eq $Isitempty) {
            Write-Host "There are no inactive computers in your Active Directory!" -ForegroundColor Green
        }
        else {
            Write-Host "List of the computers that did not update their password for +90 days is:" -ForegroundColor Green
            foreach ($Computer in $ComputerList) {
                Write-Host "$Computer" -ForegroundColor Green
            }
        }

    }
    6 {
        Find-Module ActiveDirectory
        $sites = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest().sites
        $sitesandsubnets = New-Object System.Collections.ArrayList
        Write-Host "List of found AD sites is:" -ForegroundColor Cyan
        Write-Output ""
        foreach ($site in $sites) {
            Write-Host "$($site.name)" -ForegroundColor Green
        }
        start-sleep 2
        Write-Output ""
        Write-Host "List of found subnets per site:" -ForegroundColor Cyan
        foreach ($site in $sites) {
            $temp = [PSCustomObject]@{
                'Site' = $($site.name)
                'Subnet' = $($site.subnets);
            }
            $sitesandsubnets += $temp
        }
        $sitesandsubnets
    }
    7 {
        Find-Module ActiveDirectory
        $SourceUser = (Get-UserInput -WriteOut "Insert the name of the source user:")
        Find-EmptyString -VariableName $SourceUser
        try {
            $Getuser = Get-ADUser -Identity $SourceUser -ErrorAction Stop
        }
        catch {
            Write-Host "Cannot find and object with identity $($SourceUser) under $env:USERDNSDOMAIN" -ForegroundColor Red
            Clear-UserVars
            Break
        }
        $DestinationUser = (Get-UserInput -WriteOut "Insert the name of the destination user:")
        Find-EmptyString -VariableName $DestinationUser
        try {
            $Getuser = Get-ADUser -Identity $DestinationUser -ErrorAction Stop
        }
        catch {
            Write-Host "Cannot find and object with identity $($SourceUser) under $env:USERDNSDOMAIN" -ForegroundColor Red
            Clear-UserVars
            Break
        }
        Write-Output ""
        Write-Host "Successfully found both user objects under $env:USERDNSDOMAIN" -ForegroundColor Green
        $GroupMembership = (Get-ADPrincipalGroupMembership -Identity $SourceUser).Name
        Write-Host "Cloning group membership from $($SourceUser) to $($DestinationUser)" -ForegroundColor Cyan
        Write-Host "Group list:" -ForegroundColor Green
        foreach ($Group in $GroupMembership) {
            Write-Host $Group -ForegroundColor Green
        }
        Write-Output ""
        foreach ($Group in $GroupMembership) {
            try {
                Write-Host "Adding $($DestinationUser) to group $($Group)" -ForegroundColor Cyan
                Add-ADGroupMember -Identity "$Group" -Members "$DestinationUser" -ErrorAction 
            }
            catch {
                Write-Host "User was already a member of $($Group) group." -ForegroundColor Yellow
            }
        }
    }
    8 {
        $RemoteComputer = (Get-UserInput -WriteOut "Enter the name of the computer:")
        Find-EmptyString -VariableName $RemoteComputer
        Try {
            Write-Host "Trying to get AD site of $($RemoteComputer)" -ForegroundColor Cyan
            $SiteName = invoke-command -ComputerName $RemoteComputer -ScriptBlock {
                (Get-ItemProperty "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Group Policy\State\Machine" -Name "Site-Name").'site-name'
            } -ErrorAction Stop
        }
        Catch {
            Write-Host "Cannot connect to computer - $($RemoteComputer)." -ForegroundColor Red
            Clear-UserVars
            Break
        }
        $FoundSite = [PSCustomObject]@{
            'ComputerName' = $RemoteComputer;
            'SiteName' = $SiteName;
        }
        $FoundSite
    }
    9 {
        $DomainController = (Get-UserInput -WriteOut "Type the name of the Domain Controller, or type all to test them all:")
        Find-EmptyString -VariableName $DomainController
        if ($DomainController -eq "All") {
            Write-Host "Searching for all Domain Controllers in $env:USERDNSDOMAIN" -ForegroundColor Cyan
            $DomainControllers = (Get-ADDomainController -Filter *).Name
            foreach ($DC in $DomainControllers) {
                $LDAPS = [ADSI]"LDAP://$($DC):636"
                Try {
                    $Connection = [adsi]$LDAPS
                }
                Catch {
                }
                if ($Connection.Path) {
                    Write-Host "LDAPS properly configured on $DC." -ForegroundColor Green
                }
                else {
                    Write-Host "Cannot establish LDAPS to $DC." -ForegroundColor Red
                }
            }
        }
        else {
            $LDAPS = [ADSI]"LDAP://$($DomainController):636"
            Try {
                $Connection = [adsi]$LDAPS
            }
            Catch {
            }
            if ($Connection.Path) {
                Write-Host "LDAPS properly configured on $DomainController." -ForegroundColor Green
            }
            else {
                Write-Host "Cannot establish LDAPS to $DomainController." -ForegroundColor Red
            }
        }
    }
    10 {
        $ComputerName = (Get-UserInput -WriteOut "Type the name of the computer:")
        Find-EmptyString -VariableName $ComputerName
        Try {
            Write-Host "Trying to get local Administrators from computer - $ComputerName." -ForegroundColor Cyan
            $RetrieveAdmins = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-LocalGroupMember -Name "Administrators"
            } -ErrorAction Stop
        }
        Catch {
            Write-Host "Cannot connect to computer - $ComputerName or local group does not exist." -ForegroundColor Red
            Clear-UserVars
            Break
        }
        $AdminList = New-Object System.Collections.ArrayList
        foreach ($Admin in $RetrieveAdmins) {
            $tempobject = [PSCustomObject]@{
                'Name' = $($Admin.Name).Split("\")[1];
                'Source' = $($Admin.Name).split("\")[0];
                'Class' = $(if ($Admin.Name -match '\$$') {
                    'Computer'
                }
                else {
                    $($Admin.ObjectClass)
                });
            }
            $AdminList += $tempobject
        }
        Write-Host "Found list of local Administrators is:" -ForegroundColor Green
        $AdminList
    }
    11 {
        Find-Module ActiveDirectory
        Find-Module DHCPServer
        $MACAddress = (Get-UserInput -WriteOut "Please enter the MAC address in format aa-bb-cc-dd-ee-ff:")
        Find-EmptyString -VariableName $MACAddress
        $Partition = (Get-ADDomainController -Filter * | Select-Object -First 1).partitions
        $DHCPServers = (Get-ADObject -SearchBase $Partition[3] -Filter {ObjectClass -eq "dhcpclass"} | Where-Object {$_.Name -ne "Dhcproot"}).name
        foreach ($Server in $DHCPServers) {
            $AllScopes = (Get-DhcpServerv4Scope -ComputerName $Server)
            foreach ($Scope in $AllScopes) {
                $Lease = (Get-DhcpServerv4Lease -ScopeId $($scope.scopeid) -ComputerName $Server | Where-Object {$_.clientid -eq "$MACAddress" -and $_.LeaseExpiryTime -ne $null})
                if ($null -ne $Lease) {
                    $leaseobject = [PSCustomObject]@{
                        'HostName' = $($lease.HostName);
                        'IPAddress' = $($lease.IPAddress);
                        'MAC' = $($lease.ClientId)
                        'DHCP Server' = $server;
                        'ScopeID' = $($lease.scopeid)
                    }
                }
            }
        }
        if ($null -ne $leaseobject) {
            Write-Host "Found an DHCP lease based on MAC address." -ForegroundColor Green
            $leaseobject
            Clear-UserVars
        }
        else {
            Write-Host "Cannot find any DHCP lease based on MAC address." -ForegroundColor Red
            Clear-UserVars
            Break
        }
    }
    Default {
        Write-Host "Number that you entered is out of scope or input is empty." -ForegroundColor Red
    }
}
