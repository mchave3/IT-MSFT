<#
    .SYNOPSIS
    Connects to Microsoft Graph using certificate.

    .DESCRIPTION
    The Connect-MgGraph cmdlet connects to Microsoft Graph using certificate.
    After connecting, you can perform operations on Microsoft Graph.

    .NOTES
    Author: Mickaël CHAVE
    Date: 11/07/2024
    Version: 1.0
#>

# Install module Microsoft.Graph.Authentication
Install-Module -Name Microsoft.Graph.Authentication

# Define certificate thumbprint
$thumbprint = "XXXXXXXX"

$certificatePath = "Cert:\CurrentUser\My\$($thumbprint)" # For current user
    <# OR #>
$certificatePath = "Cert:\LocalMachine\My\$($thumbprint)" # For local machine

# Get certificate
$certificate = Get-Item -Path $certificatePath

# Connect to Microsoft Graph using certificate
try {
    Write-Host "Authenticating to Microsoft Graph..."
    Connect-MgGraph -ClientId $clientID -TenantId $tenantID -Certificate $certificate -NoWelcome | Out-Null
    Write-Host "Successfully authenticated to Microsoft Graph."
}
catch {
    Write-Error "Failed to authenticate to Microsoft Graph: $($_.Exception.Message)"
}