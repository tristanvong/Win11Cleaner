function Remove-W11App {
    <#
    .SYNOPSIS
        Removes a single application (AppX or WinGet).
        Respects the DryRun flag to prevent actual deletion during testing.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [PSCustomObject]$App,

        [Parameter(Mandatory = $true)]
        [bool]$DryRun
    )

    Write-Host "Processing removal for: $($App.Name) ($($App.Id))" -NoNewline

    if ($DryRun) {
        Write-Host " [DRY RUN - NO ACTION TAKEN]" -ForegroundColor Yellow
        Write-Verbose "DryRun: Would have executed removal command for $($App.Type) package."
        return
    }

    Write-Host " [REMOVING]" -ForegroundColor Red
    
    try {
        if ($App.Type -eq 'AppX') {
            Write-Verbose "Executing: Remove-AppxPackage -Package $($App.Id)"
            Remove-AppxPackage -Package $App.Id -ErrorAction Stop
        }
        elseif ($App.Type -eq 'WinGet') {
            Write-Verbose "Executing: winget uninstall --id $($App.Id) --silent"
            
            $Process = Start-Process -FilePath "winget" -ArgumentList "uninstall", "--id", $App.Id, "--silent", "--accept-source-agreements" -PassThru -Wait -NoNewWindow
            
            if ($Process.ExitCode -ne 0) {
                throw "WinGet exited with code $($Process.ExitCode)"
            }
        }
        
        Write-Host "SUCCESS: $($App.Name) removed." -ForegroundColor Green
    }
    catch {
        Write-Error "FAILED to remove $($App.Name). Error: $_"
    }
}