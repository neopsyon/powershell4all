Function Get-AzModuleDependency {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory = $true,
            Position = 0)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('.psd1|.psm1')]
        [string[]]$ModuleFile
    )
    begin {
        $ErrorActionPreference = 'Stop'
        foreach ($file in $ModuleFile) {
            if ($false -eq $(test-path $File)) {
                Write-Error "Cannot find the file $File" -RecommendedAction "Make sure that the file exists." -ErrorAction Stop
            }
        }
    }
    process {
        foreach ($file in $ModuleFile) {
            switch -Regex ($File) {
                '.psm1' {
                    # Find text without module version
                    $getModule = Get-Content -Path $File | Select-String 'Import-Module'
                    if ($getModule) {
                        # Find text with module version
                        $getModuleVersion = $getModule | select-string 'Version'
                        if ($getModuleVersion) {
                            foreach ($line in $getModuleVersion) {
                                $codeAst = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null)
                                $commandAst = $codeAst.Find( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
                                $bindingResult = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($commandAst, $true)
                                [PSCustomObject]@{
                                    ModuleName    = $BindingResult.BoundParameters.Name.ConstantValue
                                    ModuleVersion = $BindingResult.BoundParameters.MinimumVersion.ConstantValue
                                }
                            }
                        }
                        else {
                            foreach ($line in $getModule) {
                                $codeAst = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null)
                                $commandAst = $codeAst.Find( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
                                $bindingResult = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($commandAst, $true)
                                [PSCustomObject]@{
                                    ModuleName    = $BindingResult.BoundParameters.Name.ConstantValue
                                    ModuleVersion = $BindingResult.BoundParameters.MinimumVersion.ConstantValue
                                }
                            }
                        }
                    }
                }
                '.psd1' {
                    
                }
            }
        }
    }
}