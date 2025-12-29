BeforeAll {
    . "$PSScriptRoot\..\src\Private\Import-W11Config.ps1"
    $script:TempConfig = Join-Path $env:TEMP "test-config.json"
}

Describe "Import-W11Config" {
    AfterEach {
        if (Test-Path $script:TempConfig) { Remove-Item $script:TempConfig -Force }
    }

    It "Loads valid JSON and converts it to an object" {
        $Json = @{ Settings = @{ LogPath = ""; DryRun = $true; Verbose = $false } } | ConvertTo-Json
        $Json | Out-File $script:TempConfig -Force
        
        $Config = Import-W11Config -Path $script:TempConfig
        $Config.Settings.DryRun | Should -Be $true
        $Config.Settings.Verbose | Should -Be $false
    }

    It "Sets a default LogPath if the field is empty in JSON" {
        $Json = @{ Settings = @{ LogPath = "" } } | ConvertTo-Json
        $Json | Out-File $script:TempConfig -Force
        
        $Config = Import-W11Config -Path $script:TempConfig
        $Config.Settings.LogPath | Should -Match "Win11Clean.log"
    }

    It "Throws an error if the configuration file does not exist" {
        { Import-W11Config -Path "C:\NonExistent\file.json" } | Should -Throw
    }
}