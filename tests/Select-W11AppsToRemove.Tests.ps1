BeforeAll {
    # Dot-source the private function file
    $FunctionPath = Join-Path $PSScriptRoot "..\src\Private\Select-W11AppsToRemove.ps1"
    if (Test-Path $FunctionPath) { . $FunctionPath } else { throw "Missing: $FunctionPath" }

    # Define a base mock configuration object
    $script:MockConfig = [PSCustomObject]@{
        Blacklists = [PSCustomObject]@{
            RemoveApps = @("BingNews", "CalculatorID")
        }
        Whitelists = [PSCustomObject]@{
            KeepApps = @("KeepMe")
        }
        Safeguards = [PSCustomObject]@{
            CriticalApps = @("Store", "TerminalID")
        }
    }
}

Describe "Select-W11AppsToRemove" {

    Context "Blacklist / Removal Logic" {
        It "Adds an application to the list if the Name matches a Blacklist rule" {
            $Apps = @(
                [PSCustomObject]@{ Name = "Microsoft BingNews"; Id = "Microsoft.BingNews" }
            )
            
            $Result = @(Select-W11AppsToRemove -InstalledApps $Apps -Config $script:MockConfig)
            
            $Result.Count | Should -Be 1
            $Result[0].Name | Should -Be "Microsoft BingNews"
        }

        It "Adds an application to the list if the ID matches a Blacklist rule" {
            $Apps = @(
                [PSCustomObject]@{ Name = "Microsoft Calculator"; Id = "Microsoft.CalculatorID_8wekyb3d8bbwe" }
            )
    
            $Result = @(Select-W11AppsToRemove -InstalledApps $Apps -Config $script:MockConfig)
    
            $Result.Count | Should -Be 1
            $Result[0].Id | Should -Match "CalculatorID"
        }

        It "Does not add an application if it matches neither Name nor ID in the Blacklist" {
            $Apps = @(
                [PSCustomObject]@{ Name = "SafeApp"; Id = "SafeID" }
            )
            
            $Result = Select-W11AppsToRemove -InstalledApps $Apps -Config $script:MockConfig
            
            $Result.Count | Should -Be 0
        }
    }

    Context "Whitelist Override" {
        It "Prevents removal if the application is in the Whitelist, even if blacklisted" {
            # "BingNews" is in Blacklist, but "KeepMe" is in Whitelist
            $Apps = @(
                [PSCustomObject]@{ Name = "BingNews KeepMe"; Id = "BingNews.KeepMe" }
            )
            
            $Result = Select-W11AppsToRemove -InstalledApps $Apps -Config $script:MockConfig
            
            $Result.Count | Should -Be 0
        }
    }

    Context "Safeguard / Critical App Logic" {
        It "Identifies a critical app if the Name matches a CriticalApps rule" {
            $Apps = @(
                [PSCustomObject]@{ Name = "Microsoft WindowsStore"; Id = "Microsoft.WindowsStore" }
            )
            # Must also be blacklisted to be selected for removal processing
            $Config = $script:MockConfig
            $Config.Blacklists.RemoveApps += "Store"

            $Result = Select-W11AppsToRemove -InstalledApps $Apps -Config $Config
            
            $Result[0].IsCritical | Should -Be $true
        }

        It "Identifies a critical app if the ID matches a CriticalApps rule" {
            $Apps = @(
                [PSCustomObject]@{ Name = "MyTerminal"; Id = "Microsoft.TerminalID_abc" }
            )
            $Config = $script:MockConfig
            $Config.Blacklists.RemoveApps += "TerminalID"

            $Result = Select-W11AppsToRemove -InstalledApps $Apps -Config $Config
            
            $Result[0].IsCritical | Should -Be $true
        }

        It "Adds the 'IsCritical' NoteProperty to the output objects" {
            $Apps = @(
                [PSCustomObject]@{ Name = "BingNews"; Id = "Microsoft.BingNews" }
            )
            
            $Result = Select-W11AppsToRemove -InstalledApps $Apps -Config $script:MockConfig
            
            # Check if the property exists on the object
            $Result[0] | Get-Member -Name "IsCritical" | Should -Not -BeNullOrEmpty
        }

        It "Sets IsCritical to $false for non-critical blacklisted apps" {
            $Apps = @(
                [PSCustomObject]@{ Name = "BingNews"; Id = "Microsoft.BingNews" }
            )
            
            $Result = Select-W11AppsToRemove -InstalledApps $Apps -Config $script:MockConfig
            
            $Result[0].IsCritical | Should -Be $false
        }
    }
}