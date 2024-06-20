<#
    .SYNOPSIS
    This script writes logs to a log file using a buffer to improve performance.

    .DESCRIPTION
    Logs are temporarily stored in a buffer and written to the log file periodically. This reduces the performance impact caused by frequent disk I/O operations.

    .NOTES
    Author         : Mickaël CHAVE
    Creation Date  : 2024-06-20
    Version        : 1.0

    .EXAMPLE
    To log a message:
    ```powershell
    LogWrite "This is a log message."
    ```
#>

BEGIN {
    Clear-Host

    # Create a buffer to store log messages temporarily
    $script:logBuffer = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()

    # Create a timer with a 5-second interval
    $script:timer = New-Object Timers.Timer
    $script:timer.Interval = 5000 # 5000 milliseconds = 5 seconds

    # Define the log file path
    $logDir = "C:\Windows\Logs"
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force
    }
    $script:Logfile = "$logDir\log_name.log"

    # Create a lock object for thread safety
    $script:lockObject = New-Object System.Object

    # Function to add a log message to the buffer
    Function LogWrite {
        Param ([string]$logstring)
        $logstring = (Get-Date -Format "MM-dd-yyyy - HH:mm:ss.fff") + " | $logstring"

        # Add the log message to the buffer
        $script:logBuffer.Enqueue($logstring)
    }

    # Function to write buffered logs to the log file
    Function WriteLogsBuffer {
        $lockToken = $false
        try {
            [System.Threading.Monitor]::TryEnter($script:lockObject, [ref]$lockToken)
            if ($lockToken) {
                # Transfer logs from the buffer to a temporary buffer
                $tempBuffer = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
                $log = $null
                while ($script:logBuffer.TryDequeue([ref]$log)) {
                    $tempBuffer.Enqueue($log)
                }

                # If there are logs in the buffer, write them to the log file
                if ($tempBuffer.Count -gt 0) {
                    # Create the log file if it doesn't exist
                    if (-not (Test-Path $script:Logfile)) {
                        New-Item -ItemType File -Path $script:Logfile -Force
                    }
                    # Write the buffered logs to the log file
                    $logsToWrite = @()
                    $log = $null
                    while ($tempBuffer.TryDequeue([ref]$log)) {
                        if ($null -ne $log) {
                            $logsToWrite += $log
                        }
                    }
                    # Convert $logsToWrite to an array of strings
                    $logsToWrite = $logsToWrite -as [string[]]
                    [System.IO.File]::AppendAllLines($script:Logfile, $logsToWrite)
                }
            }
        }
        catch {
            # Display an error message if writing logs fails
            Write-Host "Error occurred while writing logs to the log file: $($_.Exception.Message)"
        }
        finally {
            if ($lockToken) {
                [System.Threading.Monitor]::Exit($script:lockObject)
            }
        }
    }

    # Function to write remaining buffered logs when the script ends
    Function WriteRemainingLogsBuffer {
        $lockToken = $false
        while (-not [System.Threading.Monitor]::TryEnter($script:lockObject, [ref]$lockToken)) {
            Start-Sleep -Milliseconds 100
        }
        try {
            WriteLogsBuffer
        }
        finally {
            if ($lockToken) {
                [System.Threading.Monitor]::Exit($script:lockObject)
            }
        }
    }

    # Register an event to write logs when the timer elapses
    $script:eventId = Register-ObjectEvent -InputObject $script:timer -EventName Elapsed -SourceIdentifier "TimerElapsed" -Action {
        WriteLogsBuffer
    }

    # Start the timer
    $script:timer.Start()
}

PROCESS {
    ########################################################
    # Main Script

    # Log the start of the script
    LogWrite "Script starting..."

    <# Your script code here #>

    # EXAMPLE 1: Write a log message
    LogWrite "This is a log message."

    # EXAMPLE 2: Loop of 10000 iterations, logging each iteration
    for ($i = 0; $i -lt 10000; $i++) {
        # Log the iteration
        LogWrite "Iteration $i"

        # Update the progress bar
        Write-Progress -Activity "Processing iterations" -Status "$i of 10000 completed" -PercentComplete (($i / 10000) * 100)
    }

    # Log the end of the script
    LogWrite "Script ending..."
}

END {
    # Write any remaining logs in the buffer to the log file
    WriteRemainingLogsBuffer

    # Stop the timer and clean up
    $script:timer.Stop()
    Unregister-Event -SourceIdentifier "TimerElapsed"
    $script:timer.Dispose()

    # Dispose of the lock object
    $script:lockObject = $null
}