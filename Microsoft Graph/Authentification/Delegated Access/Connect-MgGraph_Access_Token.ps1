<#
    .SYNOPSIS
    Connects to Microsoft Graph using access token.

    .DESCRIPTION
    The Connect-MgGraph cmdlet connects to Microsoft Graph using an access token. The access token is obtained using the client credentials flow.
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
$clientsecret = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

# Set the body for the OAuth request
$body = @{
    Grant_Type    = "client_credentials"
    Scope         = "https://graph.microsoft.com/.default"
    Client_Id     = $clientID
    Client_Secret = $clientsecret
}

# Connect to Microsoft Graph using access token
try {
    Write-Host "Authenticating to Microsoft Graph..."

    # Get the OAuth token
    $oauth = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $body
    $accessToken = $oauth.access_token | ConvertTo-SecureString -AsPlainText -Force

    # Connect to Microsoft Graph
    Connect-MgGraph -AccessToken $accessToken -NoWelcome | Out-Null
    Write-Host "Successfully authenticated to Microsoft Graph."
}
catch {
    Write-Error "Failed to authenticate to Microsoft Graph: $($_.Exception.Message)"
}