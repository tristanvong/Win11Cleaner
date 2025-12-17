function Get-W11WinGetApps {
    <#
        .SYNOPSIS
        Use WinGet's list command to get installed WinGet compatible programs
        and parse the results into a PowerShell object.
    #>
    [CmdletBinding()]
    param ()

    if (-not (Get-Command "winget" -ErrorAction SilentlyContinue)) {
        Write-Warning "WinGet is not installed or not in PATH."
        return $null
    }

    # Force UTF8 encoding to prevent breakage during parsing
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8

    $RawData = winget list --accept-source-agreements --disable-interactivity | Out-String
    $Lines = $RawData -split "`r`n"
    $DataLines = $Lines | Select-Object -Skip 2
    
    $Results = @()

    foreach ($Line in $DataLines) {
        if ([string]::IsNullOrWhiteSpace($Line)) { continue }

        # skip header lines
        if ($Line -match '^Name\s+Id') { continue }
        if ($Line -match '^-+') { continue }

        # Use regex to grab the data from "winget list" command.
        if ($Line -match '^(?<Name>.+?)\s+(?<Id>[^\s]+)\s+(?<Version>[^\s]+)(\s+(?<Source>\w+))?$') {
            $Results += [PSCustomObject]@{
                Name    = $Matches.Name.Trim()
                Id      = $Matches.Id.Trim()
                Version = $Matches.Version.Trim()
                Type    = 'WinGet'
                Source  = if ($Matches.Source) { $Matches.Source } else { "Unknown" }
            }
        }
    }

    return $Results
}