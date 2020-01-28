<#
.SYNOPSIS
Returns the date of each working day.

.DESCRIPTION
Simple function which returns date of each working day in between the specified date period in the format of - yyyy-MM-dd.

.PARAMETER From
Date from which you want to calculate the working days.

.PARAMETER To
Date to which you want to calculate the working days.

.EXAMPLE
$StartDate = Get-Date -Year 2020 -Month 1 -day 1
$EndDate = Get-Date -year 2020 -Month 12 -day 31
Get-BusinessDay -From $StartDate -To $EndDate -Separate

.EXAMPLE
$StartDate = Get-Date -Year 2020 -Month 1 -day 1
$EndDate = Get-Date -year 2020 -Month 12 -day 31
Get-BusinessDay -From $StartDate -To $EndDate -Total
#>
Function Get-BusinessDay {
    [CmdletBinding(DefaultParameterSetName = 'Separate')]
    param (
        # Calcuate business days from this day.
        [Parameter(Mandatory = $true)]
        [datetime]$From,
        # Calcuate business days to this day.
        [Parameter(Mandatory = $true)]
        [datetime]$To,
        # Specify this parameter if you want to print separate working days.
        [Parameter(ParameterSetName = 'Separate')]
        [switch]$Separate,
        # Specify this parameter if you want to get the total count of working days.
        [Parameter(ParameterSetName = 'Total')]
        [switch]$Total
    )
    process {
        $ExcludeDays = @(
            [System.DayOfWeek]::Saturday
            [System.DayOfWeek]::Sunday
        )
        if ($PSCmdlet.ParameterSetName -eq 'Separate') {
            while ($From -le $To) {
                if ($From.DayOfWeek -notin $ExcludeDays) {
                    Get-Date $From -Format yyyy-MM-dd
                    $From = $From.AddDays(+1)
                }
                else {
                    $From = $From.AddDays(+1)
                }
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'Total') {
            $TotalCount = [System.Collections.ArrayList]::new()
            while ($From -le $To) {
                if ($From.DayOfWeek -notin $ExcludeDays) {
                    [void]$TotalCount.Add(1)
                    $From = $From.AddDays(+1)
                }
                else {
                    $From = $From.AddDays(+1)
                }
            }
            return ($TotalCount | Measure-Object -Sum).Sum
        }
    }
}