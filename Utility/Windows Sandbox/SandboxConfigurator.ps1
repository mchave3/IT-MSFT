<#
.SYNOPSIS
Windows Sandbox Configurator

.DESCRIPTION
This script provides a graphical user interface (GUI) for configuring and managing Windows Sandbox. It allows users to install Windows Sandbox, save and load sandbox configurations, and start the sandbox with a specific configuration file.

.NOTES
Author: Mickaël CHAVE
Date: 29/08/2024
Version: 1.0
#>

Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function New-Form {
    $form = New-Object system.Windows.Forms.Form
    $form.Text = "Windows Sandbox Configurator"
    $form.Size = New-Object System.Drawing.Size(450, 600)
    $form.StartPosition = "CenterScreen"
    return $form
}

function New-Button {
    param($text, $x, $y, $action)
    $button = New-Object system.Windows.Forms.Button
    $button.Text = $text
    $button.Size = New-Object System.Drawing.Size(150, 30)
    $button.Location = New-Object System.Drawing.Point($x, $y)
    $button.Add_Click($action)
    return $button
}

function Get-Button {
    return Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" | Select-Object -ExpandProperty State
}

function Install-Sandbox {
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart
    [System.Windows.Forms.MessageBox]::Show("Windows Sandbox installed. Please restart your computer.", "Installation Complete")
}

function Save-Config {
    param($path, $content)
    $content | Out-File -FilePath $path -Encoding utf8
    [System.Windows.Forms.MessageBox]::Show("Configuration saved to $path", "Save Complete")
}

function Start-Sandbox {
    param($configPath)
    if (Test-Path $configPath) {
        Start-Process -FilePath "C:\Windows\System32\WindowsSandbox.exe" -ArgumentList $configPath
    } else {
        [System.Windows.Forms.MessageBox]::Show("Configuration file not found!", "Error")
    }
}

function Get-SandboxConfiguration {
    param([string]$path)
    
    if (Test-Path $path) {
        # Read the content of the configuration file
        $configContent = Get-Content -Path $path -Raw
        
        Write-Host "Configuration content:"
        Write-Host $configContent
        Write-Host "End of configuration content."

        # Check and extract values from the <VGpu> tag
        if ($configContent -match '<VGpu>(.*?)</VGpu>') {
            $checkVGpu.Checked = $true
            $comboVGpu.Text = $matches[1]
        }

        # Check and extract values from the <MappedFolders>, <HostFolder>, and <ReadOnly> tags
        if ($configContent -match '<MappedFolders>.*?<MappedFolder>.*?<HostFolder>(.*?)</HostFolder>.*?<ReadOnly>(.*?)</ReadOnly>.*?</MappedFolder>.*?</MappedFolders>') {
            $hostFolder = $matches[1]
            $readOnly = $matches[2]

            Write-Host "HostFolder: $hostFolder"
            Write-Host "ReadOnly: $readOnly"

            # Set the extracted values to the UI controls
            $checkMappedFolders.Checked = $true
            $textBoxHostFolder.Text = $hostFolder
            $checkReadOnly.Checked = $readOnly -eq "True"
        } else {
            $checkMappedFolders.Checked = $false
            $textBoxHostFolder.Text = ""
            $checkReadOnly.Checked = $false
        }

        # Check and extract values from other tags
        foreach ($tag in @(
            @{ Tag = 'LogonCommand'; Control = $checkLogonCommand; TextBox = $textBoxLogonCommand },
            @{ Tag = 'Networking'; Control = $checkNetworking; ComboBox = $comboNetworking },
            @{ Tag = 'AudioInput'; Control = $checkAudioInput; ComboBox = $comboAudioInput },
            @{ Tag = 'VideoInput'; Control = $checkVideoInput; ComboBox = $comboVideoInput },
            @{ Tag = 'ClipboardRedirection'; Control = $checkClipboardRedirection; ComboBox = $comboClipboardRedirection },
            @{ Tag = 'PrinterRedirection'; Control = $checkPrinterRedirection; ComboBox = $comboPrinterRedirection },
            @{ Tag = 'ProtectedClient'; Control = $checkProtectedClient; ComboBox = $comboProtectedClient },
            @{ Tag = 'ExposeClipboard'; Control = $checkExposeClipboard; ComboBox = $comboExposeClipboard }
        )) {
            if ($configContent -match "<$($tag.Tag)>(.*?)</$($tag.Tag)>") {
                $tag.Control.Checked = $true

                # Check if the property exists before setting it
                if ($tag.TextBox -and $matches[1]) {
                    $tag.TextBox.Text = $matches[1]
                }
                if ($tag.ComboBox -and $matches[1]) {
                    $tag.ComboBox.Text = $matches[1]
                }
            } else {
                $tag.Control.Checked = $false
                if ($tag.TextBox) {
                    $tag.TextBox.Text = ""
                }
                if ($tag.ComboBox) {
                    $tag.ComboBox.Text = ""
                }
            }
        }

        # Check and extract value from <MemoryInMB>
        if ($configContent -match '<MemoryInMB>(.*?)</MemoryInMB>') {
            $memoryValue = [int]$matches[1]
            if ($memoryValue -ge $numericMemoryInMB.Minimum -and $memoryValue -le $numericMemoryInMB.Maximum) {
                $checkMemoryInMB.Checked = $true
                $numericMemoryInMB.Value = $memoryValue
            } else {
                # Set default or error value if out of range
                $checkMemoryInMB.Checked = $false
                $numericMemoryInMB.Value = $numericMemoryInMB.Minimum
            }
        } else {
            $checkMemoryInMB.Checked = $false
            $numericMemoryInMB.Value = $numericMemoryInMB.Minimum
        }

    } else {
        [System.Windows.Forms.MessageBox]::Show("Configuration file not found!", "Error")
    }
}

# Create the main form
$form = New-Form

# Check if Windows Sandbox is installed
$sandboxInstalled = Get-Button

# Create a ToolTip object
$toolTip = New-Object System.Windows.Forms.ToolTip
$toolTip.AutoPopDelay = 5000
$toolTip.InitialDelay = 1000
$toolTip.ReshowDelay = 500
$toolTip.ShowAlways =

$true

# Create buttons and controls
$installButton = New-Button "Install Sandbox" 20 20 { Install-Sandbox; $form.Close() }
$saveButton = New-Button "Save Config" 20 520 {
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "WSB files (*.wsb)|*.wsb"
    $saveFileDialog.ShowDialog() | Out-Null
    if ($saveFileDialog.FileName -ne "") {
        $wsbContent = "<Configuration>`r`n"
        
        if ($checkMappedFolders.Checked) {
            $wsbContent += "  <MappedFolders>`r`n"
            $wsbContent += "    <MappedFolder>`r`n"
            $wsbContent += "      <HostFolder>" + $textBoxHostFolder.Text + "</HostFolder>`r`n"
            $wsbContent += "      <ReadOnly>" + $checkReadOnly.Checked + "</ReadOnly>`r`n"
            $wsbContent += "    </MappedFolder>`r`n"
            $wsbContent += "  </MappedFolders>`r`n"
        }

        if ($checkLogonCommand.Checked) {
            $wsbContent += "  <LogonCommand>`r`n"
            $wsbContent += "    <Command>" + $textBoxLogonCommand.Text + "</Command>`r`n"
            $wsbContent += "  </LogonCommand>`r`n"
        }

        if ($checkNetworking.Checked) {
            $wsbContent += "  <Networking>" + $comboNetworking.Text + "</Networking>`r`n"
        }

        if ($checkVGpu.Checked) {
            $wsbContent += "  <VGpu>" + $comboVGpu.Text + "</VGpu>`r`n"
        }

        if ($checkAudioInput.Checked) {
            $wsbContent += "  <AudioInput>" + $comboAudioInput.Text + "</AudioInput>`r`n"
        }

        if ($checkVideoInput.Checked) {
            $wsbContent += "  <VideoInput>" + $comboVideoInput.Text + "</VideoInput>`r`n"
        }

        if ($checkClipboardRedirection.Checked) {
            $wsbContent += "  <ClipboardRedirection>" + $comboClipboardRedirection.Text + "</ClipboardRedirection>`r`n"
        }

        if ($checkPrinterRedirection.Checked) {
            $wsbContent += "  <PrinterRedirection>" + $comboPrinterRedirection.Text + "</PrinterRedirection>`r`n"
        }

        if ($checkProtectedClient.Checked) {
            $wsbContent += "  <ProtectedClient>" + $comboProtectedClient.Text + "</ProtectedClient>`r`n"
        }

        if ($checkMemoryInMB.Checked) {
            $wsbContent += "  <MemoryInMB>" + $numericMemoryInMB.Value + "</MemoryInMB>`r`n"
        }

        if ($checkExposeClipboard.Checked) {
            $wsbContent += "  <ExposeClipboard>" + $comboExposeClipboard.Text + "</ExposeClipboard>`r`n"
        }

        $wsbContent += "</Configuration>"
        Save-Config $saveFileDialog.FileName $wsbContent
    }
}

$startButton = New-Button "Start Sandbox" 240 520 {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "WSB files (*.wsb)|*.wsb"
    $openFileDialog.ShowDialog() | Out-Null
    if ($openFileDialog.FileName -ne "") {
        Start-Sandbox $openFileDialog.FileName
    }
}

$openButton = New-Button "Open Config" 240 480 {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "WSB files (*.wsb)|*.wsb"
    $openFileDialog.ShowDialog() | Out-Null
    if ($openFileDialog.FileName -ne "") {
        Get-SandboxConfiguration $openFileDialog.FileName
    }
}

# Add installation button if sandbox is not installed
if ($sandboxInstalled -eq "Enabled") {
    # Create and add configuration controls

    $checkMappedFolders = New-Object System.Windows.Forms.CheckBox
    $checkMappedFolders.Text = "Map a Folder"
    $checkMappedFolders.Location = New-Object System.Drawing.Point(20, 60)
    $form.Controls.Add($checkMappedFolders)
    $toolTip.SetToolTip($checkMappedFolders, "Map a folder from the host system to the sandbox environment. Example: C:\Users\user\Documents")

    $textBoxHostFolder = New-Object System.Windows.Forms.TextBox
    $textBoxHostFolder.Location = New-Object System.Drawing.Point(40, 90)
    $textBoxHostFolder.Size = New-Object System.Drawing.Size(300,20)
    $form.Controls.Add($textBoxHostFolder)

    $checkReadOnly = New-Object System.Windows.Forms.CheckBox
    $checkReadOnly.Text = "Read Only"
    $checkReadOnly.Location = New-Object System.Drawing.Point(40, 120)
    $form.Controls.Add($checkReadOnly)
    $toolTip.SetToolTip($checkReadOnly, "Set the mapped folder as read-only.")

    $checkLogonCommand = New-Object System.Windows.Forms.CheckBox
    $checkLogonCommand.Text = "Logon Command"
    $checkLogonCommand.Location = New-Object System.Drawing.Point(20, 150)
    $form.Controls.Add($checkLogonCommand)
    $toolTip.SetToolTip($checkLogonCommand, "Specify a command to run automatically when the sandbox starts.")

    $textBoxLogonCommand = New-Object System.Windows.Forms.TextBox
    $textBoxLogonCommand.Location = New-Object System.Drawing.Point(40, 180)
    $textBoxLogonCommand.Size = New-Object System.Drawing.Size(300,20)
    $form.Controls.Add($textBoxLogonCommand)

    $checkNetworking = New-Object System.Windows.Forms.CheckBox
    $checkNetworking.Text = "Networking"
    $checkNetworking.Location = New-Object System.Drawing.Point(20, 210)
    $form.Controls.Add($checkNetworking)
    $toolTip.SetToolTip($checkNetworking, "Enable or disable networking in the sandbox.")

    $comboNetworking = New-Object System.Windows.Forms.ComboBox
    $comboNetworking.Items.Add("Default")
    $comboNetworking.Items.Add("Disable")
    $comboNetworking.Location = New-Object System.Drawing.Point(40, 240)
    $comboNetworking.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboNetworking)

    $checkVGpu = New-Object System.Windows.Forms.CheckBox
    $checkVGpu.Text = "VGpu"
    $checkVGpu.Location = New-Object System.Drawing.Point(20, 270)
    $form.Controls.Add($checkVGpu)
    $toolTip.SetToolTip($checkVGpu, "Enable or disable virtual GPU support in the sandbox.")

    $comboVGpu = New-Object System.Windows.Forms.ComboBox
    $comboVGpu.Items.Add("Disable")
    $comboVGpu.Items.Add("Enable")
    $comboVGpu.Location = New-Object System.Drawing.Point(40, 300)
    $comboVGpu.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboVGpu)

    $checkAudioInput = New-Object System.Windows.Forms.CheckBox
    $checkAudioInput.Text = "Audio Input"
    $checkAudioInput.Location = New-Object System.Drawing.Point(20, 330)
    $form.Controls.Add($checkAudioInput)
    $toolTip.SetToolTip($checkAudioInput, "Enable or disable audio input in the sandbox.")

    $comboAudioInput = New-Object System.Windows.Forms.ComboBox
    $comboAudioInput.Items.Add("Disable")
    $comboAudioInput.Items.Add("Enable")
    $comboAudioInput.Location = New-Object System.Drawing.Point(40, 360)
    $comboAudioInput.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboAudioInput)

    $checkVideoInput = New-Object System.Windows.Forms.CheckBox
    $checkVideoInput.Text = "Video Input"
    $checkVideoInput.Location = New-Object System.Drawing.Point(20, 390)
    $form.Controls.Add($checkVideoInput)
    $toolTip.SetToolTip($checkVideoInput, "Enable or disable video input in the sandbox.")

    $comboVideoInput = New-Object System.Windows.Forms.ComboBox
    $comboVideoInput.Items.Add("Disable")
    $comboVideoInput.Items.Add("Enable")
    $comboVideoInput.Location = New-Object System.Drawing.Point(40, 420)
    $comboVideoInput.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboVideoInput)

    $checkClipboardRedirection = New-Object System.Windows.Forms.CheckBox
    $checkClipboardRedirection.Text = "Clipboard Redirection"
    $checkClipboardRedirection.Location = New-Object System.Drawing.Point(200, 60)
    $form.Controls.Add($checkClipboardRedirection)
    $toolTip.SetToolTip($checkClipboardRedirection, "Enable or disable clipboard redirection between host and sandbox.")

    $comboClipboardRedirection = New-Object System.Windows.Forms.ComboBox
    $comboClipboardRedirection.Items.Add("Disable")
    $comboClipboardRedirection.Items.Add("Enable")
    $comboClipboardRedirection.Location = New-Object System.Drawing.Point(220, 90)
    $comboClipboardRedirection.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboClipboardRedirection)

    $checkPrinterRedirection = New-Object System.Windows.Forms.CheckBox
    $checkPrinterRedirection.Text = "Printer Redirection"
    $checkPrinterRedirection.Location = New-Object System.Drawing.Point(200, 120)
    $form.Controls.Add($checkPrinterRedirection)
    $toolTip.SetToolTip($checkPrinterRedirection, "Enable or disable printer redirection between host and sandbox.")

    $comboPrinterRedirection = New-Object System.Windows.Forms.ComboBox
    $comboPrinterRedirection.Items.Add("Disable")
    $comboPrinterRedirection.Items.Add("Enable")
    $comboPrinterRedirection.Location = New-Object System.Drawing.Point(220, 150)
    $comboPrinterRedirection.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboPrinterRedirection)

    $checkProtectedClient = New-Object System.Windows.Forms.CheckBox
    $checkProtectedClient.Text = "Protected Client"
    $checkProtectedClient.Location = New-Object System.Drawing.Point(200, 180)
    $form.Controls.Add($checkProtectedClient)
    $toolTip.SetToolTip($checkProtectedClient, "Enable or disable Protected Client mode in the sandbox.")

    $comboProtectedClient = New-Object System.Windows.Forms.ComboBox
    $comboProtectedClient.Items.Add("Disable")
    $comboProtectedClient.Items.Add("Enable")
    $comboProtectedClient.Location = New-Object System.Drawing.Point(220, 210)
    $comboProtectedClient.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboProtectedClient)

    $checkMemoryInMB = New-Object System.Windows.Forms.CheckBox
    $checkMemoryInMB.Text = "Memory in MB"
    $checkMemoryInMB.Location = New-Object System.Drawing.Point(200, 240)
    $form.Controls.Add($checkMemoryInMB)
    $toolTip.SetToolTip($checkMemoryInMB, "Specify the amount of memory to allocate to the sandbox in megabytes.")

    $numericMemoryInMB = New-Object System.Windows.Forms.NumericUpDown
    $numericMemoryInMB.Location = New-Object System.Drawing.Point(220, 270)
    $numericMemoryInMB.Minimum = 256
    $numericMemoryInMB.Maximum = 32768
    $form.Controls.Add($numericMemoryInMB)

    $checkExposeClipboard = New-Object System.Windows.Forms.CheckBox
    $checkExposeClipboard.Text = "Expose Clipboard"
    $checkExposeClipboard.Location = New-Object System.Drawing.Point(200, 300)
    $form.Controls.Add($checkExposeClipboard)
    $toolTip.SetToolTip($checkExposeClipboard, "Expose the host clipboard to the sandbox.")

    $comboExposeClipboard = New-Object System.Windows.Forms.ComboBox
    $comboExposeClipboard.Items.Add("Disable")
    $comboExposeClipboard.Items.Add("Enable")
    $comboExposeClipboard.Location = New-Object System.Drawing.Point(220, 330)
    $comboExposeClipboard.Size = New-Object System.Drawing.Size(120, 20)
    $form.Controls.Add($comboExposeClipboard)

    $form.Controls.Add($saveButton)
    $form.Controls.Add($startButton)
    $form.Controls.Add($openButton)
} else {
    # Display message if sandbox is not installed
    $label = New-Object System.Windows.Forms.Label
    $label.Text = "Windows Sandbox is not enabled. Click the button below to install."
    $label.Location = New-Object System.Drawing.Point(20, 60)
    $form.Controls.Add($label)
    $form.Controls.Add($installButton)
}

# Run the form
$form.ShowDialog()