<#
    .SYNOPSIS
    Connects to Microsoft Graph using app registration.

    .DESCRIPTION
    The Connect-MgGraph cmdlet connects to Microsoft Graph using an app registration.
    After connecting, you can perform operations on Microsoft Graph.

    .NOTES
    Author: Mickaël CHAVE
    Date: 11/07/2024
    Version: 1.0
#>

# Install module Microsoft.Graph.Authentication
Install-Module -Name Microsoft.Graph.Authentication

# App Registration details
$tenantID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
$clientID = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

# Connect to Microsoft Graph using access token
try {
    Write-Host "Authenticating to Microsoft Graph..."
    Connect-MgGraph -ClientId $clientID -TenantId $tenantID -NoWelcome | Out-Null
    Write-Host "Successfully authenticated to Microsoft Graph."
}
catch {
    Write-Error "Failed to authenticate to Microsoft Graph: $($_.Exception.Message)"
}