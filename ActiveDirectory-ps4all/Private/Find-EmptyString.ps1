Function Find-EmptyString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [AllowEmptyString()]
        $VariableName,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$ErrorOut,
        [Parameter(Mandatory=$true)]
        [ValidateSet("Continue","Stop")]
        [string]$Action
    )
    process {
        if ($true -eq [string]::IsNullOrWhiteSpace("$VariableName")) {
            Write-Error -Message "$ErrorOut" -ErrorAction $Action
        }
    }
}