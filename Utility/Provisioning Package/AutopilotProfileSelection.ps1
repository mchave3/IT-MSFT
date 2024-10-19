Clear-Host

$version = "1.0"
$lastModified = "2021-09-01"

# Define parameters
$tenantId = "yourtenant.onmicrosoft.com"
$appId = "yourappid"
$appSecret = "yourapp"

# Install the required modules
try {
    Write-Host "`nInstalling required modules...`n" -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -WarningAction SilentlyContinue | Out-Null
    Install-Script -Name Get-WindowsAutoPilotInfo -Force -WarningAction SilentlyContinue | Out-Null
    Write-Host "`nRequired modules installed successfully.`n" -ForegroundColor Green
    start-sleep -Seconds 3
} catch {
    Write-Host "`nFailed to install required modules. Error: $($_.Exception.Message)`n" -ForegroundColor Red
    Read-Host "Press any key to exit..."
    exit
}


# Function to start the Autopilot process in the same PowerShell window
function Start-AutopilotProcess {
    param (
        [string]$tenantId,
        [string]$appId,
        [string]$appSecret,
        [string]$groupTag
    )
    & Get-WindowsAutoPilotInfo.ps1 -online -tenantId $tenantId -appId $appId -appSecret $appSecret -groupTag $groupTag

    if ($?) {
        Write-Host "`nAutopilot process completed successfully." -ForegroundColor Green
        Write-Host "`nRestarting the device to start the Autopilot process.`n" -ForegroundColor Yellow

        # Wait for 10 seconds before restarting the device
        Start-Sleep -Seconds 10
        Restart-Computer -Force
    } else {
        Write-Host "`nAutopilot process failed.`n" -ForegroundColor Red
    }
}

# Function to display the menu and get a valid selection
function Show-Menu {
    Clear-Host
    Write-Host "==============================================="
    Write-Host "      Autopilot Profile Selection Menu"
    Write-Host "==============================================="
    Write-Host $version
    Write-Host $lastModified
    Write-Host "==============================================="
    Write-Host ""
    Write-Host " 1. Standard (No Group Tag)"
    Write-Host " 2. Industrial (Group Tag: Industrial)"
    Write-Host " 3. KIOSK (Group Tag: KIOSK)"
    Write-Host " 0. Exit"
    Write-Host ""
}

# Function to handle user input
function Get-UserSelection {
    $validSelection = $false
    while (-not $validSelection) {
        Show-Menu
        $selection = Read-Host "Please enter the number of your choice"
        
        switch ($selection) {
            "1" {
                $groupTag = ""
                Write-Host "`nYou selected: Standard (No Group Tag)`n" -ForegroundColor Green
                $validSelection = $true
            }
            "2" {
                $groupTag = "Industriel"
                Write-Host "`nYou selected: Industrial (Group Tag: Industrial)`n" -ForegroundColor Green
                $validSelection = $true
            }
            "3" {
                $groupTag = "KIOSK"
                Write-Host "`nYou selected: KIOSK (Group Tag: KIOSK)`n" -ForegroundColor Green
                $validSelection = $true
            }
            "0" {
                Write-Host "`nExiting the script.`n" -ForegroundColor Yellow
                exit
            }
            default {
                Write-Host "`nInvalid selection. Please try again.`n" -ForegroundColor Red
                Start-Sleep -Seconds 3
            }
        }
    }
    return $groupTag
}

# Get the valid user selection
$groupTag = Get-UserSelection

# Start the Autopilot process with the selected group tag in the same window
Start-AutopilotProcess -tenantId $tenantId -appId $appId -appSecret $appSecret -groupTag $groupTag