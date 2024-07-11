<#
    .SYNOPSIS
    Connects to Microsoft Graph using certificate thumbprint.

    .DESCRIPTION
    The Connect-MgGraph cmdlet connects to Microsoft Graph using certificate thumbprint.
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

$certificatePath = "Cert:\CurrentUser\My" # For current user
    <# OR #>
$certificatePath = "Cert:\LocalMachine\My" # For local machine

# Get certificate thumbprint
$certificateName = "Microsoft Graph Certificate"
$certificateThumbprint = Get-ChildItem -Path $certificatePath | Where-Object { $_.Subject -match $certificateName } | Select-Object -First 1 FriendlyName, Subject, Thumbprint

# Connect to Microsoft Graph using certificate thumbprint
try {
    Write-Host "Authenticating to Microsoft Graph..."
    Connect-MgGraph -ClientId $clientID -TenantId $tenantID -CertificateThumbprint $($certificateThumbprint.Thumbprint) -NoWelcome | Out-Null
    Write-Host "Successfully authenticated to Microsoft Graph."
}
catch {
    Write-Error "Failed to authenticate to Microsoft Graph: $($_.Exception.Message)"
}