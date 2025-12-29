Describe "Get-W11AppxApps" {
    It "Transforms native AppX objects into the project's standard format" {
        . "$PSScriptRoot\..\src\Private\Get-W11AppxApps.ps1"
        $MockNative = [PSCustomObject]@{ Name = "Calculator"; PackageFullName = "Microsoft.Calculator"; Version = "1.0" }
        Mock Get-AppxPackage { return $MockNative }

        $Result = Get-W11AppxApps
        $Result[0].Type | Should -Be "AppX"
        $Result[0].Id | Should -Be "Microsoft.Calculator"
    }
}