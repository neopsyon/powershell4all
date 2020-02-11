Function New-ModuleStructure {
    [CmdletBinding()]
    param (
        # Path where you want to store your module structure.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Path,
        # Name of your module.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $ModuleName,
        # Name of the Author.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Author,
        # Description of your module.
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]
        $Description
    )
    process {
        # Create module directory structure.
        $DirectoryStructure = @("Private","Public","en-US")
        foreach ($Item in $DirectoryStructure) {
            New-Item -Path "$Path\$ModuleName\$Item" -ItemType Directory
        }
        # Create module and related files.
        New-Item -Path "$Path\$ModuleName\$ModuleName.psm1" -ItemType File
        New-Item -Path "$Path\$ModuleName\en-US\about_$ModuleName.help.txt" -ItemType File
        New-ModuleManifest -Path "$Path\$ModuleName\$ModuleName.psd1" `
                           -RootModule "$ModuleName.psm1" `
                           -Description "$Description" `
                           -Author "$Author"
$Text = @'
$Public  = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
#Dot source the files.
    Foreach($import in @($Public + $Private))
    {
        Try
        {
            . $import.fullname
        }
        Catch
        {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

Export-ModuleMember -Function $Public.Basename
'@
    $Text | out-file "$Path\$ModuleName\$ModuleName.psm1"
    }
}