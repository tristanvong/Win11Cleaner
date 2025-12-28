function Get-W11ManualSelection {
    <#
    .SYNOPSIS
        Provides a GUI for manual application selection.
    
    .DESCRIPTION
        Uses 'Out-GridView' to allow users to pick applications for removal and then pick which of those should be marked as critical (confirmation required before they are deleted).
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$InstalledApps
    )

    # Select Blacklist (Apps to Remove)
    $Targeted = $InstalledApps | Out-GridView -Title "Select Applications for REMOVAL (Blacklist)" -PassThru

    if ($null -eq $Targeted) {
        Write-Host "No applications selected for removal. Exiting." -ForegroundColor Yellow
        return @()
    }

    # Select Safeguards (Critical Apps)
    $Critical = $Targeted | Out-GridView -Title "Select Applications requiring CONFIRMATION (Safeguards/Critical)" -PassThru

    foreach ($App in $Targeted) {
        $IsCritical = $false
        if ($null -ne $Critical -and $Critical.Id -contains $App.Id) {
            $IsCritical = $true
        }
        # Add the property required by Remove-W11App
        $App | Add-Member -NotePropertyName "IsCritical" -NotePropertyValue $IsCritical -Force
    }

    return $Targeted
}