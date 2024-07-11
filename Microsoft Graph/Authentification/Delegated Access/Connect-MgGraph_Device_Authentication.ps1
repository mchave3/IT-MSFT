<#
    .SYNOPSIS
    Connects to Microsoft Graph using device authentication.

    .DESCRIPTION
    The Connect-MgGraph cmdlet connects to Microsoft Graph using device authentication.
    After connecting, you can perform operations on Microsoft Graph.

    .NOTES
    Author: Mickaël CHAVE
    Date: 11/07/2024
    Version: 1.0
#>

# Install module Microsoft.Graph.Authentication
Install-Module -Name Microsoft.Graph.Authentication

# Define the required scopes
$scopes = @(
    "User.Read.All",
    "Group.ReadWrite.All"
)

# Connect to Microsoft Graph using device authentication
try {
    Write-Host "Authenticating to Microsoft Graph..."
    Connect-MgGraph -Scopes $scopes -UseDeviceCode -NoWelcome | Out-Null
    Write-Host "Successfully authenticated to Microsoft Graph."
}
catch {
    Write-Error "Failed to authenticate to Microsoft Graph: $($_.Exception.Message)"
}