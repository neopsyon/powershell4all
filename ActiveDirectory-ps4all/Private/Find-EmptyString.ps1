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
        $Stringtest = [string]::IsNullOrEmpty("$VariableName")
        if ($true -eq $Stringtest) {
            Write-Error -Message "$ErrorOut" -ErrorAction $Action
        }
    }
}