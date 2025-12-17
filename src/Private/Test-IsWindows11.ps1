function Test-IsWindows11 {
    <#
    .SYNOPSIS
        Checks if the current operating system is Windows 11.
    #>
    [CmdletBinding()]
    param()

    $OS = Get-CimInstance -ClassName Win32_OperatingSystem
    
    # Windows 11 build starts from 22000
    # (https://learn.microsoft.com/en-us/windows/release-health/windows11-release-information)
    if ($OS.BuildNumber -ge 22000 -and $OS.Caption -match "Windows") {
        return $true
    }
    
    return $false
}