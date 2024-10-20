Clear-Host

$version = "1.1"
$lastModified = "2024-10-20"

# Define parameters (secure handling recommended)
$tenantId = "yourtenantId"
$appId = "yourappid"
$appSecret = "yourapp"

# Function to install required modules
function Install-RequiredModules {
    try {
        Write-Host "`nChecking and installing required modules..." -ForegroundColor Yellow
        
        # Install NuGet provider if not already installed
        if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
            Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force -WarningAction SilentlyContinue | Out-Null
        }

        # Install the WindowsAutopilotInfo script if not present
        if (-not (Get-Command Get-WindowsAutoPilotInfo.ps1 -ErrorAction SilentlyContinue)) {
            Install-Script -Name Get-WindowsAutoPilotInfo -Force -WarningAction SilentlyContinue | Out-Null
        }

        Write-Host "`nRequired modules installed successfully." -ForegroundColor Green
    } catch {
        Write-Host "`nFailed to install required modules. Error: $($_.Exception.Message)" -ForegroundColor Red
        Read-Host "Press any key to exit..."
        exit
    }
}

# Function to start the Autopilot process
function Start-AutopilotProcess {
    param (
        [string]$tenantId,
        [string]$appId,
        [string]$appSecret,
        [string]$groupTag
    )

    Write-Host "`nStarting Autopilot process for group tag: $groupTag..." -ForegroundColor Yellow
    try {
        # Call the Autopilot script
        & Get-WindowsAutoPilotInfo.ps1 -online -tenantId $tenantId -appId $appId -appSecret $appSecret -groupTag $groupTag

        if ($?) {
            Write-Host "`nAutopilot process completed successfully." -ForegroundColor Green
            Write-Host "`nRestarting the device to finalize the process." -ForegroundColor Yellow
            Start-Sleep -Seconds 10
            Restart-Computer -Force
        } else {
            Write-Host "`nAutopilot process failed." -ForegroundColor Red
        }
    } catch {
        Write-Host "`nError occurred during the Autopilot process: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Function to display the menu and get a valid selection
function Show-Menu {
    Clear-Host
    Write-Host "==============================================="
    Write-Host "      Autopilot Profile Selection Menu"
    Write-Host "==============================================="
    Write-Host "Version: $version"
    Write-Host "Last Modified: $lastModified"
    Write-Host "==============================================="
    Write-Host ""
    Write-Host " 1. Standard"
    Write-Host " 2. Industrial"
    Write-Host " 3. KIOSK"
    Write-Host " 0. Exit"
    Write-Host ""
}

# Function to handle user input and return a valid group tag
function Get-UserSelection {
    $groupTag = $null
    while (-not $groupTag) {
        Show-Menu
        $selection = Read-Host "Please enter the number of your choice"
        
        switch ($selection) {
            "1" { 
                $groupTag = "Standard"
                Write-Host "`nYou selected: Standard (Group Tag: Standard)" -ForegroundColor Green
            }
            "2" { 
                $groupTag = "Industrial"
                Write-Host "`nYou selected: Industrial (Group Tag: Industrial)" -ForegroundColor Green
            }
            "3" { 
                $groupTag = "KIOSK"
                Write-Host "`nYou selected: KIOSK (Group Tag: KIOSK)" -ForegroundColor Green
            }
            "0" { 
                Write-Host "`nExiting the script." -ForegroundColor Yellow
                exit
            }
            default { 
                Write-Host "`nInvalid selection. Please try again." -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    }
    return $groupTag
}

# Main Script Execution

Install-RequiredModules

# Get the valid user selection for group tag
$groupTag = Get-UserSelection

# Start the Autopilot process with the selected group tag
Start-AutopilotProcess -tenantId $tenantId -appId $appId -appSecret $appSecret -groupTag $groupTag
