function Get-W11TextSelection {
    <#
    .SYNOPSIS
        Provides a command-line interface for manual application selection.
    
    .DESCRIPTION
        Bypasses the application configuration rules from settings.json and provides a two-step interactive console process:
        1. Removal Selection: Repeatedly prompts the user to search for applications. Matches are selected from a list by index or skipped.
        2. Safeguard Selection: Prompts the user to mark specific applications from the targeted list as "Critical".
        
        Entering a blank input at the main search prompt finishes the selection phase.

    .PARAMETER InstalledApps
        An array of application objects gathered from the system.

    .OUTPUTS
        System.Array. An array of PSCustomObjects representing the user's targeted apps, updated with the 'IsCritical' property.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [array]$InstalledApps
    )

    $Targeted = @()
    Write-Host "`n--- Text Selection Mode (Removal List) ---" -ForegroundColor Cyan
    Write-Host "Search for apps to remove. Press Enter on a blank line to finish." -ForegroundColor Gray

    # Step 1: Targeted Apps Selection Loop
    while ($true) {
        $Query = Read-Host "`nSearch App Name or ID (or Enter to finish)"
        if ([string]::IsNullOrWhiteSpace($Query)) { break }

        $SearchResults = @($InstalledApps | Where-Object { $_.Name -like "*$Query*" -or $_.Id -like "*$Query*" })

        if ($SearchResults.Count -eq 0) {
            Write-Warning "No matches found for '$Query'."
        }
        elseif ($SearchResults.Count -eq 1) {
            $App = $SearchResults[0]
            if ($Targeted.Id -contains $App.Id) {
                Write-Host "App '$($App.Name)' is already in the list." -ForegroundColor Yellow
            } else {
                $Confirm = Read-Host "Add '$($App.Name)' [$($App.Type)] to removal list? (y/n)"
                if ($Confirm -eq 'y') { 
                    $Targeted += $App
                    Write-Host "Added." -ForegroundColor Green 
                }
            }
        }
        else {
            Write-Host "Multiple matches found:" -ForegroundColor Yellow
            for ($i = 0; $i -lt $SearchResults.Count; $i++) {
                Write-Host " [$i] $($SearchResults[$i].Name) ($($SearchResults[$i].Id))"
            }
            
            $IndexInput = Read-Host "Enter the number to add (or 's' to skip)"
            
            # One or more digits
            if ($IndexInput -match '^\d+$') {
                $Index = [int]$IndexInput
                if ($Index -ge 0 -and $Index -lt $SearchResults.Count) {
                    $App = $SearchResults[$Index]
                    if ($Targeted.Id -contains $App.Id) {
                        Write-Host "Already in list." -ForegroundColor Yellow
                    } else {
                        $Targeted += $App
                        Write-Host "Added '$($App.Name)'." -ForegroundColor Green
                    }
                } else {
                    Write-Warning "Invalid index selection: $Index is out of range."
                }
            }
        }
    }

    if ($Targeted.Count -eq 0) {
        Write-Host "No applications selected. Exiting." -ForegroundColor Yellow
        return @()
    }

    # Step 2: Critical Safeguard Marking
    Write-Host "`n--- Safeguard Selection (Critical Apps) ---" -ForegroundColor Cyan
    Write-Host "Mark which apps should require a final 'Y/N' confirmation prompt." -ForegroundColor Gray

    foreach ($App in $Targeted) {
        $IsCritical = $false
        $AppName = $App.Name.Trim()
        $Choice = Read-Host "Mark '$AppName' as Critical? (y/n)"
        
        if ($Choice -eq 'y') { $IsCritical = $true }
        
        $App | Add-Member -NotePropertyName "IsCritical" -NotePropertyValue $IsCritical -Force
    }

    return $Targeted
}