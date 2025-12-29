BeforeAll {
    . "$PSScriptRoot\..\src\Private\Get-W11TextSelection.ps1"
    
    $script:MockApps = @(
        [PSCustomObject]@{ Name = "Calculator App"; Id = "Calc.App"; Type = "AppX" }
    )
}

Describe "Get-W11TextSelection" {
    It "Adds an app to the targeted list and marks it critical based on user input" {
        # Mocking 4 sequential user inputs: 
        # 1. Search query: 'Calc'
        # 2. Confirmation to add: 'y'
        # 3. Finish search: (empty string)
        # 4. Mark as Critical: 'y'
        $UserInput = "Calc", "y", "", "y"
        $script:Counter = 0
        Mock Read-Host { 
            $script:Counter++
            return $UserInput[$script:Counter-1] 
        }

        $Result = Get-W11TextSelection -InstalledApps $script:MockApps
        
        $Result.Count | Should -Be 1
        $Result[0].Name | Should -Be "Calculator App"
        $Result[0].IsCritical | Should -Be $true
    }
}