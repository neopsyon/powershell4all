<#
.SYNOPSIS
Helper function which is reading the cmdlet/function structure and presenting it as a help system in an easy way

.DESCRIPTION
The function which is meant to present cmdlet/function help in an easy and readable way, for the people who find Powershell to help syntax hard to interpret.
It is capable of showing three different structures, including - Mandatory Parameters, Parameter Sets, and Alias Parameters.
Every structure will have the accompanying rich information about every parameter.

.PARAMETER Cmdlet
Specify the Cmdlet or a function name that you want to inspect

.PARAMETER MandatoryParameter
Specify this switch parameter if you want to show mandatory parameters of the targeted Cmdlet

.PARAMETER ParameterSet
Specify this switch parameter if you want to show parameter sets and it's parameters of the target Cmdlet

.PARAMETER AliasParameter
Specify this switch parameter if you want to show parameter aliases and matching parameters of the target Cmdlet

.EXAMPLE
Get-CmdletDetail -Cmdlet Get-Service -MandatoryParameter

.EXAMPLE
Get-CmdletDetail -Cmdlet Get-Service -ParameterSet

.EXAMPLE
Get-CmdletDetail -Cmdlet Get-Service -AliasParameter

.EXAMPLE
Get-CmdletDetail -Function Set-CustomThing

#>
Function Get-CmdletDetail {
    [CmdletBinding(DefaultParameterSetName = 'MandatoryParameter')]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true,
            Position = 0)]
        [Alias('Function')]
        [ValidatePattern('.-.')]
        [string]$Cmdlet,
        # Parameter help description
        [Parameter(ParameterSetName = 'MandatoryParameter')]
        [switch]$MandatoryParameter,
        # Parameter help description
        [Parameter(ParameterSetName = 'ParameterSet')]
        [switch]$ParameterSet,
        # Parameter help description
        [Parameter(ParameterSetName = 'AliasParameter')]
        [switch]$AliasParameter
    )
    begin {
        $ErrorActionPreference = 'Stop'
        try {
            [void]($FindCommand = Get-Command $Cmdlet)
        }
        catch {
            Write-Error "$_" -ErrorAction Stop
        }
    }
    process {
        [hashtable]$CommandParameters = $FindCommand.Parameters
        switch ($PSCmdlet.ParameterSetName) {
            'MandatoryParameter' {
                foreach ($Key in $CommandParameters.Keys) {
                    $FindParameterObject = $CommandParameters.($Key).Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
                    if (-not [string]::IsNullOrWhiteSpace($FindParameterObject)) {
                        if ($FindParameterObject.Mandatory -eq $true) {
                            $CmdletStructure = $CommandParameters.($Key)
                            [PSCustomObject]@{
                                ParameterName = $CmdletStructure.Name
                                Mandatory     = $true
                                ParameterSet  = $CmdletStructure.ParameterSets.keys -join ','
                                ParameterType = ($CmdletStructure.ParameterType.Name)
                                Aliases       = ($CmdletStructure.Aliases -join ',').Trim('{}')
                                Position = $(if ($FindParameterObject.Position -eq '-2147483648') {$false} else {$FindParameterObject.Position})
                                ValueFromPipeline = $FindParameterObject.ValueFromPipeline
                                ValueFromPipelineByPropertyName = $FindParameterObject.ValueFromPipelineByPropertyName
                            }
                        }
                    }
                }
            }
            'AliasParameter' {
                $AliasCollection = [System.Collections.ArrayList]::new()
                foreach ($Key in $CommandParameters.Keys) {
                    $FindParameterObject = $CommandParameters.($Key).Attributes | Where-Object { $_ -is [System.Management.Automation.AliasAttribute] }
                    if ($FindParameterObject) {
                        $CmdletStructure = $CommandParameters.($Key)
                        $AliasParameterOut = [PSCustomObject]@{
                            AliasName     = ($CmdletStructure.Aliases -join ',').Trim('{}')
                            ParameterSet  = $CmdletStructure.ParameterSets.keys -join ','
                            ParameterType = ($CmdletStructure.ParameterType.Name)
                            ParameterName = $CmdletStructure.Name 
                        }
                        [void]$AliasCollection.Add($AliasParameterOut)
                    }
                }
                $AliasCollection | Sort-Object -Property ParameterSet
            }
            'ParameterSet' {
                $ParameterSetCollection = [System.Collections.ArrayList]::new()
                foreach ($Key in $CommandParameters.Keys) {
                    $CmdletStructure = $CommandParameters.($Key)
                    $ParameterSetOut = [PSCustomObject]@{
                        ParameterName = $CmdletStructure.Name
                        ParameterSet  = $CmdletStructure.ParameterSets.keys -join ','
                        ParameterType = ($CmdletStructure.ParameterType.Name)
                        Aliases       = ($CmdletStructure.Aliases -join ',').Trim('{}')
                    }
                    [void]$ParameterSetCollection.Add($ParameterSetOut)
                }
                $ParameterSetCollection | Sort-Object -Property ParameterSet
            }
        }
    }
}