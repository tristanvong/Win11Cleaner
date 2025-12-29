BeforeAll {
    . "$PSScriptRoot\..\src\Private\Write-W11Undo.ps1"
    $script:UndoPath = Join-Path $env:TEMP "test-undo.json"
}

Describe "Write-W11Undo" {
    AfterEach {
        if (Test-Path $script:UndoPath) { Remove-Item $script:UndoPath -Force }
    }

    It "Filters out AppX apps and only logs WinGet apps" {
        $Apps = @(
            [PSCustomObject]@{ Name = "AppX1"; Type = "AppX"; Id = "ID1" },
            [PSCustomObject]@{ Name = "WinGet1"; Type = "WinGet"; Id = "ID2" }
        )
        
        Write-W11Undo -RemovedApps $Apps -Path $script:UndoPath
        
        $History = Get-Content $script:UndoPath | ConvertFrom-Json
        $History.Apps.Count | Should -Be 1
        $History.Apps[0].Name | Should -Be "WinGet1"
    }

    It "Increments the generation number for each new execution" {
        $App = @([PSCustomObject]@{ Name = "WinGet1"; Type = "WinGet"; Id = "ID1" })
        
        Write-W11Undo -RemovedApps $App -Path $script:UndoPath
        Write-W11Undo -RemovedApps $App -Path $script:UndoPath
        
        $History = Get-Content $script:UndoPath | ConvertFrom-Json
        $History.Count | Should -Be 2
        $History[1].Generation | Should -Be 2
    }
}