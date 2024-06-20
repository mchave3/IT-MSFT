BEGIN{
    Clear-Host

    # Create a buffer to hold the logs
    $script:logBuffer = New-Object System.Collections.Queue
    $script:currentBuffer = $null

    # Create a timer
    $script:timer = New-Object Timers.Timer
    $script:timer.Interval = 5000 # Interval set to 5 second (1000 milliseconds)

    # Create a lock object
    $script:lockObject = New-Object System.Object

    # Define the log file path
    $logDir = "C:\Windows\Logs"
    $script:Logfile = "$logDir\log_name.log"

    # Add an event that is triggered when the timer elapses
    $script:eventId = Register-ObjectEvent -InputObject $script:timer -EventName Elapsed -SourceIdentifier "TimerElapsed" -Action {
        WriteLogsBuffer
    }

    # Start the timer
    $script:timer.Start()
}

PROCESS{
    # Function for logging
    Function LogWrite
    {
        Param
        (
            [Parameter(Mandatory=$true, Position=0)]
            [string] $logstring,
            [Parameter(Mandatory=$false, Position=1)]
            [string] $level
        )
        switch ( $level )
        {
            "Info" { $logLevel = 1 }
            "Warning" { $logLevel = 2 }
            "Error" { $logLevel = 3 }
            default { $logLevel = 1 }
        }

        $logDate = Get-Date -Format "MM-dd-yyyy"
        $logTime = Get-Date -Format "HH:mm:ss.fff-00"
        $logstring = "<![LOG[$logstring]LOG]!><time=""$logTime"" date=""$logDate"" component="""" context="""" type=""$logLevel"">"

        # Add the log to the buffer
        $script:logBuffer.Enqueue($logstring)
    }

    # Function to write logs from the buffer to the file
    Function WriteLogsBuffer
    {
        # Use the lock to prevent simultaneous execution
        $lockToken = $false
        $streamWriter = $null
        $fileStream = $null
        try {
            [System.Threading.Monitor]::TryEnter($script:lockObject, [ref]$lockToken)
            if ($lockToken) {
                # Copy the buffer and clear the original
                $script:currentBuffer = $script:logBuffer.Clone()
                $script:logBuffer.Clear()

                # Check if the log file exists and create it if it doesn't
                if (-not (Test-Path $script:Logfile)) {
                    New-Item -ItemType File -Path $script:Logfile -Force
                }
                # Open the file with a file lock
                $fileStream = [System.IO.File]::Open($script:Logfile, [System.IO.FileMode]::Append, [System.IO.FileAccess]::Write, [System.IO.FileShare]::Read)
                $streamWriter = New-Object System.IO.StreamWriter($fileStream)
                while($currentBuffer.Count -gt 0)
                {
                    $log = $currentBuffer.Dequeue()
                    $streamWriter.WriteLine($log)
                }
            }
        }
        catch {
            # Write the exception to a error log file
            Write-Host "$_.Exception.Message"
        }
        finally {
            if ($lockToken) {
                if ($null -ne $streamWriter) {
                    try {
                        $streamWriter.Close()
                        $streamWriter.Dispose()
                    }
                    catch {
                        # Write the exception to a error log file
                        Write-Host "$_.Exception.Message"
                    }
                }
                if ($null -ne $fileStream) {
                    try {
                        $fileStream.Close()
                        $fileStream.Dispose()
                    }
                    catch {
                        # Write the exception to a error log file
                        Write-Host "$_.Exception.Message"
                    }
                }
                [System.Threading.Monitor]::Exit($script:lockObject)
            }
        }
    }

    ########################################################
    # Main Script

    LogWrite "Script starting..."

    # Main code
    try {
        <#
        Script..
        #>

        foreach ($int in (0..1000000)) {
            LogWrite "$int"
        }


    }
    catch {
        LogWrite "An error occurred: $_" -level "Error"
    }

    LogWrite "Script ending..."
}

END{
    # Check if the buffer exists
    if ($null -ne $script:logBuffer) {
        # Write remaining logs in the buffer
        WriteLogsBuffer

        # Wait for the buffers to be empty
        while ($script:logBuffer.Count -gt 0 -or ($null -ne $script:currentBuffer -and $script:currentBuffer.Count -gt 0)) {
            Start-Sleep -Milliseconds 100
        }

        # Clear the buffers
        $script:logBuffer.Clear()
        $script:currentBuffer.Clear()
    }

    # Check if the timer exists
    if ($null -ne $script:timer) {
        # Stop the timer
        $script:timer.Stop()

        # Unregister the timer event
        Unregister-Event -SourceIdentifier "TimerElapsed"

        # Dispose the timer
        $script:timer.Dispose()
    }

    # Dispose the lock object
    if ($null -ne $script:lockObject) {
        $script:lockObject = $null
    }
}