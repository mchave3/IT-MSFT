<#
    .SYNOPSIS
    This script checks if specific Appx packages are installed or provisioned on a Windows system.

    .DESCRIPTION
    This script checks if specific Appx packages are installed or provisioned on a Windows system.
    If it finds matches, it logs them and exits with code 1. Otherwise, it exits with code 0.

    .NOTES
    Author: Mickael CHAVE
    Date: 27/07/2023
    Version: 1.0
#>

Clear-Host

# Function for logging
Function LogWrite {
    Param ([string]$logstring)
    $logstring = (Get-Date -Format "MM-dd-yyyy - HH:mm:ss.fff") + " | $logstring"
    Add-Content $Logfile -Value $logstring
}

########################################################
# Main Script

$logDir = "C:\ProgramData\Microsoft\IntuneManagementExtension\Logs"
$Logfile = "$logDir\RemoveAppx_Detection.log"

LogWrite "Script starting..."

# Appx list
$Appx = @(
    'Clipchamp.Clipchamp'
    'Microsoft.549981C3F5F10'
    'Microsoft.BingNews'
    'Microsoft.BingWeather'
    'Microsoft.GamingApp'
    'Microsoft.GetHelp'
    'Microsoft.Getstarted'
    'Microsoft.Microsoft3DViewer'
    'Microsoft.MicrosoftOfficeHub'
    'Microsoft.MicrosoftSolitaireCollection'
    'Microsoft.MicrosoftStickyNotes'
    'Microsoft.Office.OneNote'
    'Microsoft.OneConnect'
    'Microsoft.People'
    'Microsoft.PowerAutomateDesktop'
    'Microsoft.SkypeApp'
    'Microsoft.Todos'
    'Microsoft.WindowsAlarms'
    'Microsoft.WindowsCommunicationsApps'
    'Microsoft.WindowsFeedbackHub'
    'Microsoft.WindowsMaps'
    'Microsoft.WindowsSoundRecorder'
    'Microsoft.Xbox.TCUI'
    'Microsoft.XboxApp'
    'Microsoft.XboxGameOverlay'
    'Microsoft.XboxGamingOverlay'
    'Microsoft.XboxIdentityProvider'
    'Microsoft.XboxSpeechToTextOverlay'
    'Microsoft.YourPhone'
    'Microsoft.ZuneMusic'
    'Microsoft.ZuneVideo'
    'MicrosoftTeams'
)

# Get Windows version
$Winver = Get-ComputerInfo | Select-Object OSName,OSDisplayVersion
LogWrite "Current OS : $($Winver.OsName) $($Winver.OSDisplayVersion)"

# Get all installed Appx packages
$InstalledPackages = Get-AppxPackage -AllUsers

# Initialize an empty array to store matching packages
$MatchingPackages = @()

# Check for matches with Appx lists
foreach ($package in $InstalledPackages) {
    $packageName = $package.Name
    if ($Appx -contains $packageName) {
        $MatchingPackages += $packageName
    }
}

# Get provisioned packages
$ProvisionedPackages = Get-AppxProvisionedPackage -Online

# Check for matches with Appx lists in provisioned packages
foreach ($package in $ProvisionedPackages) {
    $packageName = $package.DisplayName
    if ($Appx -contains $packageName) {
        $MatchingPackages += $packageName
    }
}

# Log matching packages
if ($MatchingPackages.Count -gt 0) {
    LogWrite "Matching Appx packages found:"
    foreach ($match in $MatchingPackages) {
        LogWrite "- $match"
    }
    LogWrite "Exiting with code 1."
    exit 1
}

LogWrite "No matching Appx packages found. Exiting with code 0."
LogWrite "Script ending..."
exit 0