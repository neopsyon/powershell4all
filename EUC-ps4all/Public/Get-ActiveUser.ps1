Function Get-ActiveUser {
    [CmdletBinding()]
    param (
        # Parameter help description
        [Parameter(Mandatory=$true,
        Position=1)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ComputerName
    )
    process {
        try {
            $GetUsers = Invoke-Command -ComputerName $ComputerName -ScriptBlock {quser | Select-Object -skip 1} -ErrorAction Stop
            $Userlist = New-Object System.Collections.ArrayList
            foreach ($User in $GetUsers) {
                $Username = ($User.substring(1)).split(" ")[0]
                $Userlist += $Username
            }
            $Finallist = [PSCustomObject]@{
                Hostname = $ComputerName
                Activeuser = $Userlist -join ","
            }
            $Finallist
        }
        catch {
            Write-Error "$_"
        }
    }
}