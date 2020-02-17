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
        foreach ($File in $ModuleFile) {
            if ($false -eq $(test-path $File)) {
                Write-Error "Cannot find the file $File" -RecommendedAction "Make sure that the file exists."
            }
        }
    }
    process {
        foreach ($File in $ModuleFile) {
            switch -Regex ($File) {
                '.psm1' {
                    # Find text without module version
                    $GetModule = Get-Content -Path $File | Select-String 'Import-Module'
                    if ($GetModule) {
                        # Find text with module version
                        $GetModuleVersion = $GetModule | select-string 'Version'
                        if ($GetModuleVersion) {
                            foreach ($line in $GetModuleVersion) {
                                $CodeAst = [System.Management.Automation.Language.Parser]::ParseInput($line, [ref]$null, [ref]$null)
                                $CommandAst = $CodeAst.Find( { $args[0] -is [System.Management.Automation.Language.CommandAst] }, $true)
                                $BindingResult = [System.Management.Automation.Language.StaticParameterBinder]::BindCommand($CommandAst, $true)
                                [PSCustomObject]@{
                                    ModuleName    = $BindingResult.BoundParameters.Name.ConstantValue
                                    ModuleVersion = $BindingResult.BoundParameters.MinimumVersion.ConstantValue
                                }
                            }
                        }
                        else {
                        }
                    }
                }
                '.psd1' {
                    
                }
            }
        }
    }
}