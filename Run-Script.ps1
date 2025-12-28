<#
.SYNOPSIS
    Execution wrapper for the Win11Clean module.

.DESCRIPTION
    This script serves as the primary entry point for the user. It performs the following setup:
    1. Locates and imports the Win11Clean module manifest (.psd1).
    2. Loads the 'settings.json' configuration file from the local config directory.
    3. Triggers the main 'Invoke-Win11Clean' function with verbosity settings derived from the JSON config.
    
.PARAMETER NoConfirm
    If present, bypasses manual 'Y' confirmation prompts for applications marked as 'Critical' in the configuration.

.PARAMETER Undo
    If present, triggers 'Invoke-W11Undo' to restore previously removed applications instead of running a new cleanup.

.PARAMETER Manual
    If present, bypasses the (application) rules defined in 'settings.json' (DryRun and Verbose (switches) are still turned on/off with this file) and launches a graphical user interface (GUI) to manually select which apps to remove and which to tag as critical.

.EXAMPLE
    .\Run-Script.ps1
    Runs the full cleanup process using settings defined in config\settings.json.

.EXAMPLE
    .\Run-Script.ps1 -NoConfirm
    Runs the cleanup process and automatically approves the removal of critical applications without user intervention.

.EXAMPLE
    .\Run-Script.ps1 -Undo
    Displays the removal history and allows the user to restore applications to a previous state.

.EXAMPLE
    .\Run-Script.ps1 -Manual
    Launches an interactive selection process using 'Out-GridView' to pick applications for removal and safeguard tagging.

.NOTES
    This script must be run from the root of the project folder so it can correctly resolve the relative paths to the 'src' and 'config' directories.
#>
[CmdletBinding()]
param (
    [switch]$NoConfirm,
    [switch]$Undo,
    [switch]$Manual,
    [switch]$Text
)

$ModulePath = Join-Path -Path $PSScriptRoot -ChildPath "src\Win11Clean.psd1"
Import-Module -Name $ModulePath -Force

$ConfigPath = Join-Path -Path $PSScriptRoot -ChildPath "config\settings.json"
$UndoPath = Join-Path $env:TEMP "Win11CleanUndo.json"

$Config = Get-Content -Path $ConfigPath | ConvertFrom-Json

if ($Undo) {
    Invoke-W11Undo -UndoPath $UndoPath
} else {
    Invoke-Win11Clean -Verbose:$Config.Settings.Verbose -NoConfirm:$NoConfirm -UndoPath $UndoPath -Manual:$Manual -Text:$Text
}