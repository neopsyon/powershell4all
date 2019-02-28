Function Test-QuickConnect {
    [CmdletBinding()]
    param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [Alias('Computer','ComputerName')]
        [string]$Name
    )
    process {
        if ($false -eq (Test-Connection -ComputerName $Name -Count 1 -Quiet)) {
            Write-Warning ('[{0}] : Unable to connect to computer. Skipping.' -F $Name)
            Continue
        }
    }
}