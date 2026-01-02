# Win11Cleaner
Win11Cleaner is a professional, modular PowerShell automation tool designed to help users remove default Windows 11 applications and bloatware. It provides a structured, safe, and transparent way to manage system cleanliness by combining detection from both Microsoft Store (AppX) and WinGet package managers.

# How to use
## Prerequisites
* OS: Windows 11
* WinGet
* Newest PowerShell version ($IsWindows is not shipped with the older PowerShell 5.1 (default version))

# Installation
1. Clone the project to a local directory.
2. No further installation is required as this project is designed to run as a portable PowerShell module.

## Execute the script:
1. Customize your preferences in [settings.json](./config/settings.json).
2. Open a PowerShell terminal as Administrator.
3. Execute the wrapper script from the project root:

> [!TIP]  
> A combination of options is possible such as `./Run-Script.ps1 -NoConfirm -Manual -Text -Script`. However it will only be run in Manual/Out-GridView mode because it filters the interaction mode in [Invoke-Win11Clean.ps1](src/Public/Invoke-Win11Clean.ps1). If the -Undo parameter is given such as: `./Run-Script.ps1 -NoConfirm -Manual -Text -Undo` the project will only run the undo functionality because this is filtered in [Run-Script.ps1](Run-Script.ps1).

```ps
# Standard execution (with prompts for critical apps)
./Run-Script.ps1
```

```ps
# Force execution (bypasses security prompts)
./Run-Script.ps1 -NoConfirm
```

```ps
# Undo functionality (restores previously uninstalled WinGet apps)
./Run-Script.ps1 -Undo
```

```ps
# Manual selection mode (GUI interface)
./Run-Script.ps1 -Manual
```

```ps
# Text selection mode (Command-line interface)
./Run-Script.ps1 -Text
```

# How it works
The tool follows a strict automated workflow managed by the [Invoke-Win11Clean](./src/Public/Invoke-Win11Clean.ps1) function:

* Environment Check: Runs [Test-IsWindows11](./src/Private/Test-IsWindows11.ps1)  to confirm operating system compatibility.
* Config Initialization: Imports settings.json and automatically resolves the log path to the user's %TEMP% directory if not explicitly defined.
* Discovery: Scans for all AppX and WinGet packages currently installed on the system.
* Filtering: Cross-references discovered apps against user-defined Blacklist, Whitelist, and Safeguard rules.
* Execution Policy:
    * If DryRun is false, it waits for 10 seconds so the user has time to stop the script.
    * No-Confirm Mode: If the `-NoConfirm` switch is used, Safeguard prompts ("are you sure you want to uninstall application X?") for critical apps are bypassed.
    * Iterates through targeted apps, applying provider-specific (AppX or WinGet) removal commands.
* History Logging: After a successful cleanup, removed WinGet applications are recorded as a new "Generation" in a JSON-based undo log. The location of this file can be specified but defaults to the user's %TEMP% folder.

# Configuration guide
The [config/settings.json](./config/settings.json) file is the central control for the tool.

## Settings
> [!NOTE]  
> DryRun defaults to TRUE (safe mode). Set it to FALSE in [config/settings.json](./config/settings.json) to enable actual application removal.

* LogPath: Destination for the log file (leave empty for default temporary storage path).
* DryRun: Set to true to test settings without deleting anything.
* Verbose: Set to true for detailed console output during the execution of the PowerShell tool.

## Application rules
* Whitelists (KeepApps): Apps here are never removed, even if they match a blacklist rule.
* Blacklists (RemoveApps): Strings that target apps for removal (example: "Google Chrome").
* Safeguards (CriticalApps): Apps that require a "Y" (yes confirmation) manual prompt even if blacklisted.

# Technical Architecture
The project follows a modular design pattern, separating internal logic (Private) from the user accessible interface (Public).

## Directory Structure
* [Run-Script.ps1](Run-Script.ps1): The entry point wrapper that handles module importation and parameter passing.
* [src/Win11Clean.psd1](src/Win11Clean.psd1): The Module Manifest defining exported functions and metadata.
* [src/Public/](src/Public/): Contains the main function ([Invoke-Win11Clean.ps1](src/Public/Invoke-Win11Clean.ps1)), the application discovery function ([Get-W11InstalledSoftware.ps1](src/Public/Get-W11InstalledSoftware.ps1)) and the main undo functionality ([Invoke-W11Undo.ps1](src/Public/Invoke-W11Undo.ps1)).
* [src/Private/](src/Private/): Contains helper functions for OS checks, JSON parsing, logging, and provider-specific removal logic (AppX and WinGet).
* [tests/](tests/): A comprehensive Pester testing suite providing code coverage for both public and private functions.

# Sources and References

* All basic knowledge regarding PowerShell learnt from school course 'System Automation & Scripting' @ EhB
* Generative AI was used as aid in the making of this project:
    * [Conversation 1](https://gemini.google.com/share/aa0a06dc3d63)
    * [Conversation 2](https://gemini.google.com/share/cfecc6121cc9)
    * [Conversation 3](https://gemini.google.com/share/916eb3ec899d)
    * [Conversation 4](https://gemini.google.com/share/bf38b1b3c1c7)
    * [Conversation 5](https://gemini.google.com/share/cf15dab9b40a)
    * [Conversation 6](https://gemini.google.com/share/07c4d93c2ee7)
* [$IsWindows automatic variable](https://stackoverflow.com/questions/44703646/determine-the-os-version-linux-and-windows-from-powershell)
* [GitHub Action Pester integration](https://pester.dev/docs/usage/code-coverage#integrating-with-github-actions)
* [WinGet documentation](https://learn.microsoft.com/en-us/windows/package-manager/winget/)