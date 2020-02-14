Function Get-ModuleDependency {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true,
            Position=0)]
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
                    if (-not [string]::IsNullOrWhiteSpace($GetModule)) {
                        # Find text with module version
                        $
                    }
                }
                '.psd1' {
                    
                }
            }
        }
    }
}