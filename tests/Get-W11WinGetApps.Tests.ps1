Describe "Get-W11WinGetApps" {
    It "Correctly parses the winget list text table" {
        . "$PSScriptRoot\..\src\Private\Get-W11WinGetApps.ps1"
        $Table = "Name Id Version Source`r`n-----------------------`r`nRandomApp ID_RandomApp 1.0 winget"
        Mock Get-Command { return $true }
        Mock winget { return $Table }

        $Result = Get-W11WinGetApps
        $Result[0].Name | Should -Be "RandomApp"
        $Result[0].Source | Should -Be "winget"
    }
}