<#
    .SYNOPSIS
    This script checks if specific Appx packages are installed or provisioned on a Windows system.

    .DESCRIPTION
    This script checks if specific Appx packages are installed or provisioned on a Windows system.
    If it finds matches, it logs them and exits with code 1. Otherwise, it exits with code 0.

    .NOTES
    Author: Mickael CHAVE
    Date: 22/06/2024
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

# Get all installed and provisioned Appx packages
$InstalledPackages = Get-AppxPackage -AllUsers | Select-Object -ExpandProperty Name
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Select-Object -ExpandProperty DisplayName

# Combine all packages to check
$AllPackages = $InstalledPackages + $ProvisionedPackages

# Find matching packages
$MatchingPackages = $Appx | Where-Object { $AllPackages -contains $_ }

# Log matching packages
if ($MatchingPackages) {
    LogWrite "Matching Appx packages found:"
    $MatchingPackages | ForEach-Object { LogWrite "- $_" }
    LogWrite "Exiting with code 1."
    exit 1
}

LogWrite "No matching Appx packages found. Exiting with code 0."
exit 0