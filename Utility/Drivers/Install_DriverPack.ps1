<#
.SYNOPSIS
    Install all drivers in the current directory and subdirectories.

.DESCRIPTION
    This script will install all drivers in the current directory and subdirectories.

.NOTES
    Author:  Mickaël CHAVE
    Date:    15/09/2024
    Version: 1.0
#>

Clear-Host

# Get all drivers in the current directory and subdirectories
$driversPath = "C:\Drivers"
$drivers = Get-ChildItem -Path $driversPath -Recurse -Filter "*.inf"

# Install all drivers
if ($drivers.count -ge "0") {
    Write-Warning "$($drivers.count) drivers found !"
    foreach ($driver in $drivers) {
        try {
            Write-Host "Installing driver $($driver.FullName) ..."
            pnputil.exe -i -a $driver.FullName
            Write-Host "Driver installed successfully."
        }
        catch {
            Write-Error "Error while installing driver $($driver.FullName) : $($_.Exception.Message)"
        }
    }
    Write-Warning "All drivers installed successfully."
}
else {
    Write-Warning "No drivers found !"
}