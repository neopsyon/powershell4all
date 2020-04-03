function Get-ModuleVersion {
    [cmdletbinding()]
    param (
        # Path to the module descriptor file.
        [Parameter(Mandatory)]
        [ValidatePattern('.psd1')]
        [string]$ModulePath
    )
    begin {
        if ($false -eq $(Test-Path -Path $ModulePath)) {
            Write-Error "Cannot verify path provided, make sure the module descriptor file exists." -ErrorAction Stop
        }
    }
    process {
        $findVersion = (Get-Module -ListAvailable $ModulePath).Version
        [string]$finalVersion = ''
        'Major','Minor','Build' | ForEach-Object {
            if ([int]$findVersion.$($_) -gt -1) {
                $finalVersion += $findVersion.$($_)
            }
        }
        <# Adding dots between version numbers #>
        [int]$lastPosition = $finalVersion.Length - 1
        1..$lastPosition | ForEach-Object {
            if ($_ -eq 1) {
                $finalVersion = $finalVersion.Insert($_,'.')
            }
            else {
                $finalVersion = $finalVersion.Insert($($_ + 1),'.')
            }
        }
        return($finalVersion)
    }
}