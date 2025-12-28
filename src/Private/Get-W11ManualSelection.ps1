function Get-W11ManualSelection {
    <#
    .SYNOPSIS
        Provides a GUI for manual application selection.
    
    .DESCRIPTION
        Bypasses the application configuration rules from settings.json and provides a two-step interactive selection process using 'Out-GridView':
        1. Removal Selection: Lists all detected applications. The user selects which apps should be added to the session's blacklist.
        2. Safeguard Selection: Filters the list down to the user's previous selection. The user then picks which of these are "Critical" and should require a manual confirmation prompt during the removal phase.
        
        This is useful for users who want to perform cleanups without editing the 'settings.json' file.

    .PARAMETER InstalledApps
        An array of application objects gathered from the system.

    .OUTPUTS
        System.Array. An array of PSCustomObjects that have been updated with the 'IsCritical' property based on user interaction.

    .EXAMPLE
        $Selected = Get-W11ManualSelection -InstalledApps $AllApps
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