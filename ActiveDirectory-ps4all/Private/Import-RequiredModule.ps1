Function Import-RequiredModule {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true,
        Position=0,
        HelpMessage="Enter the name of the module.")]
        [ValidateNotNullOrEmpty()]
        [array[]]$ModuleName
    )
    process {
        foreach ($Module in $ModuleName) {
            try {
                Import-Module -Name $Module -ErrorAction Stop
            }
            catch {
                Write-Error -Message "Can't import required module. $_"
            }
        }
    }
}