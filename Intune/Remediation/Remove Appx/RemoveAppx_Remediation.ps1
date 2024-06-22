<#
    .SYNOPSIS
    Removes the Windows Appx packages present in the $Appx list.

    .DESCRIPTION
    This script removes the specified Appx packages from all users and also removes provisioned packages on a Windows system. Actions and errors are logged.

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
$Logfile = "$logDir\RemoveAppx_Remediation.log"

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

# Get appx packages
$InstalledPackages = Get-AppxPackage -AllUsers | Where-Object {($Appx -contains $_.Name)}

# Remove all Appx packages from the list
foreach ($AppxPackage in $InstalledPackages) {
    try {
        LogWrite "Removing Appx package: $($AppxPackage.Name)"
        Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
        LogWrite "Successfully removed package: $($AppxPackage.Name)"
    } catch {
        LogWrite "Failed to remove package: $($AppxPackage.Name). Error: $_"
    }
}

# Get provisioned packages
$ProvisionedPackages = Get-AppxProvisionedPackage -Online | Where-Object {($Appx -contains $_.DisplayName)}

# Remove all provisioned Appx packages from the list
foreach ($ProvPackage in $ProvisionedPackages) {
    try {
        LogWrite "Removing provisioned Appx package: $($ProvPackage.DisplayName)"
        Remove-AppxProvisionedPackage -Online -PackageName $ProvPackage.PackageName -ErrorAction Stop
        LogWrite "Successfully removed provisioned package: $($ProvPackage.DisplayName)"
    } catch {
        LogWrite "Failed to remove provisioned package: $($ProvPackage.DisplayName). Error: $_"
    }
}

LogWrite "Script ending..."