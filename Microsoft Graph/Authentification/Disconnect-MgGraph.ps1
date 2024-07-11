<#
    .SYNOPSIS
    Disconnects from Microsoft Graph.

    .DESCRIPTION
    This script disconnects from Microsoft Graph by calling the Disconnect-MgGraph function. If a connection to Microsoft Graph exists, the script attempts to disconnect and displays a success message. 
    If the disconnection fails, an error message is displayed.

    .NOTES
    Author: Mickaël CHAVE
    Date: 11/07/2024
    Version: 1.0
#>

CLEAN {
    if (Get-MgContext) {
        try {
            Disconnect-MgGraph
            Write-Host "Disconnected from Microsoft Graph"
        }
        catch {
            Write-Error "Failed to disconnect from Microsoft Graph : $($_.exception.message)"
        }
    }
}