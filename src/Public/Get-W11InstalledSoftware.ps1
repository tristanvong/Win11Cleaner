function Get-W11InstalledSoftware {
    <#
    .SYNOPSIS
        Retrieves a combined list of installed software from AppX and WinGet.

    .DESCRIPTION
        This function optimizes the discovery phase by concurrently executing the 'Get-W11AppxApps' and 
        'Get-W11WinGetApps' tasks. It utilizes 'ForEach-Object -Parallel' to run these provider-specific 
        scans in isolated runspaces, significantly reducing total detection time.
        
        To ensure these private functions are accessible within isolated threads, the function 
        dynamically resolves the 'Private' folder path and dot-sources the required script files 
        into each thread's memory before execution.

    .OUTPUTS
        System.Array. An array of PSCustomObjects containing Name, Id, Version, Type, and Source.

    .NOTES
        This function requires PowerShell 7.0 or higher to support the -Parallel parameter.

    .EXAMPLE
        $AllSoftware = Get-W11InstalledSoftware
        $AllSoftware | Where-Object { $_.Type -eq 'WinGet' }
    #>
    [CmdletBinding()]
    param ()

    Write-Verbose "Detecting installed software in parallel..."
    
    $PrivateFolder = Join-Path $PSScriptRoot "..\Private"

    $DiscoveryJobs = @(
        @{ Function = "Get-W11AppxApps";   File = "Get-W11AppxApps.ps1" },
        @{ Function = "Get-W11WinGetApps"; File = "Get-W11WinGetApps.ps1" }
    )

    $Results = $DiscoveryJobs | ForEach-Object -Parallel {
        # Create the full path to the private script file
        $ScriptPath = Join-Path $using:PrivateFolder $_.File
        
        if (Test-Path $ScriptPath) {
            # Get acces to the private functions (Get-W11AppxApps, Get-W11WinGetApps) in this thread and call them
            . $ScriptPath
            & $_.Function
        }
        else {
            Write-Error "Parallel thread could not find script at: $ScriptPath"
        }
    } -ThrottleLimit 2

    $Total = $Results | Sort-Object Name
    
    Write-Verbose "Total applications detected: $($Total.Count)"
    return $Total
}