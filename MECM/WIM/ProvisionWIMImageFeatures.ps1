<#
    .SYNOPSIS
    This script is used to add and enable Windows features in a WIM image.

    .DESCRIPTION
    This script mounts a WIM image, adds and enables Windows features in the image, and then unmounts the image.

    .NOTES
    Author: Mickael CHAVE
    Date: 29/06/2024
    Version: 1.1
#>

Clear-Host

# Define the WIM file path
$wimDirectory = "C:\Example\Sources\Masters"
$wimPath = "$wimDirectory\wim_name.wim"

# Define the path for Windows SxS files
$windowsSxsPath = "C:\Example\Scripts\OSD\UpdateWIM\WindowsSxs"

# Define the directory to mount the WIM image
$mountDir = "C:\Example\Scripts\OSD\UpdateWIM\Mount"

# Function to check if a path exists and create if not
function Test-PathExists {
    param (
        [string]$Path
    )
    if (-Not (Test-Path -Path $Path)) {
        Write-Host "Creating path: $Path"
        New-Item -ItemType Directory -Path $Path | Out-Null
    }
}

# Function to run DISM commands
function Invoke-Dism {
    param (
        [string]$Arguments
    )
    try {
        Start-Process -FilePath "dism.exe" -ArgumentList $Arguments -NoNewWindow -Wait -ErrorAction Stop
    }
    catch {
        Write-Error "Error occurred with DISM command: $Arguments. Error: $($_.Exception.Message)"
        Remove-Mount
        exit
    }
}

# Function to unmount WIM
function Remove-Mount {
    Write-Host "Cleaning up by unmounting $mountDir"
    try {
        Start-Process -FilePath "dism.exe" -ArgumentList "/Unmount-Wim /MountDir:`"$mountDir`" /Discard" -NoNewWindow -Wait -ErrorAction Stop
        Write-Host "$mountDir unmounted successfully."
    }
    catch {
        Write-Error "Error occurred while unmounting: $($_.Exception.Message)"
    }
}

# Check if paths exist
if (-Not (Test-Path -Path $wimPath)) {
    Write-Error "WIM file not found: $wimPath"
    exit
}
Test-PathExists -Path $mountDir
Test-PathExists -Path $windowsSxsPath

# List WIM indexes and names
Write-Host "Listing WIM indexes..."
$wimInfo = dism /Get-WimInfo /WimFile:$wimPath
$indexInfo = $wimInfo | Select-String -Pattern "Index : (\d+)|Name : (.*)"

$indexes = @()
$names = @()
for ($i = 0; $i -lt $indexInfo.Count; $i += 2) {
    $index = $indexInfo[$i].Matches[0].Groups[1].Value
    $name = $indexInfo[$i + 1].Matches[0].Groups[1].Value
    $indexes += $index
    $names += $name
}

if ($indexes.Count -gt 1) {
    Write-Host "The WIM file contains multiple indexes. Please select an index to proceed:"
    for ($i = 0; $i -lt $indexes.Count; $i++) {
        Write-Host "$($i + 1). Index $($indexes[$i]) - $($names[$i])"
    }
    $selection = Read-Host "Enter the number of the index you want to use"
    if ($selection -lt 1 -or $selection -gt $indexes.Count) {
        Write-Error "Invalid selection. Exiting."
        exit
    }
    $index = $indexes[$selection - 1]
} else {
    $index = $indexes[0]
    Write-Host "Only one index found: Index $index - $($names[0])"
}

# Mount the WIM
Write-Host "Mounting WIM (Index $index)..."
Invoke-Dism -Arguments "/Mount-Wim /WimFile:`"$wimPath`" /Index:$index /MountDir:`"$mountDir`""
Write-Host "$wimPath mounted successfully."

# Add and enable all CAB files in the Windows SxS directory
$cabFiles = Get-ChildItem -Path $windowsSxsPath -Filter *.cab
foreach ($cabFile in $cabFiles) {
    $featureName = $cabFile.Name -replace "Microsoft-Windows-(.*?)-OnDemand-Package.*", '$1'
    Write-Host "Adding and enabling package: $featureName from $($cabFile.FullName)"
    Invoke-Dism -Arguments "/Image:`"$mountDir`" /Add-Package /PackagePath:`"$($cabFile.FullName)`" /LimitAccess"
    Write-Host "$featureName added successfully."

    # Enable the feature
    Write-Host "Enabling feature: $featureName"
    Invoke-Dism -Arguments "/Image:`"$mountDir`" /Enable-Feature /FeatureName:`"$featureName`" /All /LimitAccess"
    Write-Host "$featureName enabled successfully."
}

# Unmount the WIM
Write-Host "Unmounting $mountDir"
Invoke-Dism -Arguments "/Unmount-Wim /MountDir:`"$mountDir`" /Commit"
Write-Host "$mountDir unmounted successfully."