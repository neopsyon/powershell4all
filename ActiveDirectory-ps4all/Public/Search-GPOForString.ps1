#Requires -Module grouppolicy
<#
.SYNOPSIS
Searches group policy objects for specific string.

.DESCRIPTION
Invokes a search against all group policy objects in the specific domain, gathers the in-memory report which is xml type and executes a query search against for the specific string.

.PARAMETER String
String that you are looking for.

.EXAMPLE
PS C:\> Search-GPOForString -String "certificate"

GPO Name                      GPO ID                              
--------                      ------                              
AutoEnrollment - Certificates 1d20f399-7aeb-4492-954a-e3bff2944cb1
Default Domain Policy         31b2f340-016d-11d2-945f-00c04fb984f9
BitLocker                     6c005315-ce5d-471c-9eb4-00b18049379b
SmartCard Cryptography        77a20bbc-2259-464b-8a97-186ea1453ed7

.INPUTS
System.String

.OUTPUTS
PSCustomObject
#>
Function Search-GPOForString {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true,
        Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$String
    )
    begin {
        $GpoCollection = [System.Collections.ArrayList]::new()
    }
    process {
        $AllGObjects = (Get-GPO -All -Domain $env:USERDNSDOMAIN)
        Find-EmptyString -VariableName $AllGObjects -ErrorOut "Cannot find any group policy object in domain $env:USERDNSDOMAIN" -Action Stop
        foreach ($Gpo in $AllGObjects) {
            Write-Verbose -Message "Searching for specific string at group policy object with id $($Gpo.Id)"
            $Report = (Get-GPOReport -Guid $($Gpo.Id) -ReportType Xml)
            if ($Report -match $String) {
                $TempObject = [PSCustomObject]@{
                    'GPO Name' = $($Gpo.DisplayName)
                    'GPO ID' = $($Gpo.Id)
                }
                [void]$GpoCollection.Add($TempObject)
            }
        }
        $GpoCollection
    }
}