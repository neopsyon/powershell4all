<#
.SYNOPSIS 
Removes a user profile from computer, both from registry and users path, if any of those is present.

.PARAMETER UserName
Specifies the name of the user which profile is supposed to be removed.

.PARAMETER ComputerName
Specifies the name of the computer from where user profile is supposed to be removed.

.EXAMPLE 
Remove-UserProfile -UserName nemanja.jovic -ComputerName remotecomputername

#>
Function Remove-UserProfile {
    [CmdletBinding()]
    param (
        # Name of the target computer where you want to wipe the user profile.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $UserName,
        # Name of the user that you want to wipe.
        [Parameter(Mandatory=$true)]
        [string]
        $ComputerName
    )
    begin {
        # Check that computer is not a Domain Controller.
        $CheckDC = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
            if ($env:LOGONSERVER -eq "\\$(hostname)") {
                Write-Output "Yes"
            }
        } -ErrorAction Stop
        if ("Yes" -eq $CheckDC) {
            Write-Error "The target computer is a domain controller, this action would wipe a domain user." -ErrorAction Stop
        }
    }
    process {
        [System.Collections.ArrayList]$IdList = @()
        try {
            # Check if the user has active sessions and kill them if any.
            [array]$SessionId = (quser /SERVER:$ComputerName 2>$null) | Select-String "$UserName " -ErrorAction Stop
            if ($true -eq [string]::IsNullOrWhiteSpace($SessionId)) {
                Write-Verbose "No active sessions found for user $UserName on remote computer $ComputerName"
            }
            else {
                foreach ($Id in $SessionId) {
                    $Id = ((($Id.ToString()).substring("1")) -replace ' {2,}', ",").split(",")[2]
                    [void]$IdList.Add($Id)
                }
                foreach ($Id in $IdList) {
                    logoff $Id /SERVER:$ComputerName
                }
            }
            # Check for the user profile paths in the registry.
            $RegistryList = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                [array]$ItemList = (Get-ChildItem -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList").name
                foreach ($Item in $ItemList) {
                    $Item = $Item.Replace("HKEY_LOCAL_MACHINE","HKLM:")
                    Get-ItemProperty -Path $Item | Where-Object {$_.ProfileImagePath -eq "C:\Users\$using:UserName" -or $_.ProfileImagePath -eq "C:\Users\$using:UserName.$env:USERDOMAIN"}
                }
            }
            # Additional condition check, if the registry hive is removed related to user profile but path at C:\Users still exists.
            $ProfileList = Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                Get-ChildItem -Path "C:\Users" | Where-Object {$_.Name -eq $using:UserName -or $_.Name -eq "$using:UserName.$env:USERDOMAIN"}
            }
            # If user profile is not found in registry and in Users path.
            if ($true -eq [string]::IsNullOrWhiteSpace($RegistryList) -and $true -eq [string]::IsNullOrWhiteSpace($ProfileList)) {
                Write-Error "Cannot find user matching $UserName in registry or in the users profile path." -ErrorAction Stop
            }
            # If user profile is not found in registry, but found in Users path.
            elseif ($true -eq [string]::IsNullOrWhiteSpace($RegistryList) -and $false -eq [string]::IsNullOrWhiteSpace($ProfileList)) {
                Write-Output "User profile found in users profile path, but not in registry."
                foreach ($Profile in $ProfileList) {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        Remove-Item $($using:Profile.FullName) -Recurse -Force -Confirm:$false
                    } -ErrorAction Stop
                    Write-Output "Successfully removed user profile from path $($Profile.FullName)"
                }
            }
            # If user profile is found in registry, but not in Users path.
            elseif ($false -eq [string]::IsNullOrWhiteSpace($RegistryList) -and $true -eq [string]::IsNullOrWhiteSpace($ProfileList)) {
                Write-Output "User profile found in registry, but not in Users path."
                foreach ($Item in $RegistryList) {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($using:Item.PSChildName)" -Recurse -Force -Confirm:$false
                    } -ErrorAction Stop
                    Write-Output "Successfully removed user profile from registry, SID - $($Item.PSChildName)"
                }
            }
            # If user is found both in registry and Users path.
            elseif ($false -eq [string]::IsNullOrWhiteSpace($RegistryList) -and $false -eq [string]::IsNullOrWhiteSpace($ProfileList)) {
                foreach ($Profile in $ProfileList) {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        Remove-Item $($using:Profile.FullName) -Recurse -Force -Confirm:$false
                    } -ErrorAction Stop
                    Write-Output "Successfully removed user profile from path $($Profile.FullName)"
                }
                foreach ($Item in $RegistryList) {
                    Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                        Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\$($using:Item.PSChildName)" -Recurse -Force -Confirm:$false
                    } -ErrorAction Stop
                    Write-Output "Successfully removed user profile from registry, SID - $($Item.PSChildName)"
                }
            }
        }
        catch {
            Write-Error "$_" -ErrorAction Stop
        }
    }
}