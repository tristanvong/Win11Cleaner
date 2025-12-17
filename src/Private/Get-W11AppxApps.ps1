function Get-W11AppxApps {
    <#
        .SYNOPSIS
        Wrap Get-AppxPackage to return a Powershell object.
    #>
    [CmdletBinding()]
    param ()

    $Apps = Get-AppxPackage -PackageTypeFilter Main
    $Results = @()

    foreach ($App in $Apps) {
        $Results += [PSCustomObject]@{
            Name    = $App.Name
            Id      = $App.PackageFullName
            Version = $App.Version
            Type    = 'AppX'
            Source  = 'AppxPackage'
        }
    }

    return $Results
}