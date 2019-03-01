Function Test-Ldaps {
    [cmdletbinding()]
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$DC
    )
    process {
        try {
            $LDAPS = [ADSI]"LDAP://$($DC):636"
            $Connection = [ADSI]$LDAPS
        }
        catch {
            Write-Error -ErrorRecord $_
        }
        if ($Connection.Path) {
            Write-Verbose "LDAPS is properly configured on $DC"
            $true
        }
        else {
            Write-Warning -Message "Cannot establish LDAPS connection to $DC"
            $false
        }
    }
}
