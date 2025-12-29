BeforeAll {
    . "$PSScriptRoot\..\src\Private\Remove-W11App.ps1"
    . "$PSScriptRoot\..\src\Private\Write-Log.ps1"
}

Describe "Remove-W11App" {
    BeforeEach {
        $script:MockApp = [PSCustomObject]@{ 
            Name = "TestApp"; 
            Id = "TestID"; 
            Type = "AppX"; 
            IsCritical = $false 
        }
    }

    It "Does not perform removal when DryRun is true" {
        $Result = Remove-W11App -App $script:MockApp -DryRun $true
        $Result | Should -Be $null
    }

    It "Successfully calls Remove-AppxPackage for AppX apps" {
        Mock Remove-AppxPackage { return }
        $Result = Remove-W11App -App $script:MockApp -DryRun $false
        
        Assert-MockCalled Remove-AppxPackage
        $Result | Should -Be $true
    }

    It "Successfully calls winget uninstall for WinGet apps" {
        $script:MockApp.Type = "WinGet"
        Mock Start-Process { return [PSCustomObject]@{ ExitCode = 0 } }
        
        $Result = Remove-W11App -App $script:MockApp -DryRun $false
        
        Assert-MockCalled Start-Process
        $Result | Should -Be $true
    }

    It "Prompts for confirmation on Critical apps unless NoConfirm is used" {
        $script:MockApp.IsCritical = $true
        Mock Read-Host { return "Y" }
        Mock Remove-AppxPackage { return }
        
        Remove-W11App -App $script:MockApp -DryRun $false -NoConfirm $false
        
        Assert-MockCalled Read-Host
    }
}