Function Find-EmptyString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        Position=1)]
        [AllowEmptyString()]
        [string]$VariableName,
        [Parameter(Mandatory=$true,
        Position=2)]
        [ValidateNotNullOrEmpty()]
        [string]$ErrorOut,
        [Parameter(Mandatory=$true,
        Position=3)]
        [ValidateSet("Continue","Stop")]
        [string]$Action
    )
    process {
        if ($true -eq [string]::IsNullOrWhiteSpace("$VariableName")) {
            Write-Error -Message "$ErrorOut" -ErrorAction $Action
        }
    }
}