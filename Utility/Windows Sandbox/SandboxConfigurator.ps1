<#
.SYNOPSIS
Windows Sandbox Configurator

.DESCRIPTION
This script provides a graphical user interface (GUI) for configuring and managing Windows Sandbox. It allows users to install Windows Sandbox, save and load sandbox configurations, and start the sandbox with a specific configuration file.

.NOTES
Author: Mickaël CHAVE
Date: 29/08/2024
Version: 1.4
#>

Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function New-Form {
    $form = New-Object system.Windows.Forms.Form
    $form.Text = "Windows Sandbox Configurator"
    $form.Size = New-Object System.Drawing.Size(800, 600)
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

function New-TextBox {
    param($x, $y, $width, $height)
    $textBox = New-Object system.Windows.Forms.TextBox
    $textBox.Size = New-Object System.Drawing.Size($width, $height)
    $textBox.Location = New-Object System.Drawing.Point($x, $y)
    return $textBox
}

function New-ListBox {
    param($x, $y, $width, $height)
    $listBox = New-Object system.Windows.Forms.ListBox
    $listBox.Size = New-Object System.Drawing.Size($width, $height)
    $listBox.Location = New-Object System.Drawing.Point($x, $y)
    return $listBox
}

function New-CheckBox {
    param($text, $x, $y)
    $checkBox = New-Object system.Windows.Forms.CheckBox
    $checkBox.Text = $text
    $checkBox.Location = New-Object System.Drawing.Point($x, $y)
    return $checkBox
}

function Install-Sandbox {
    Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart
    [System.Windows.Forms.MessageBox]::Show("Windows Sandbox installed. Please restart your computer.", "Installation Complete")
    Update-UI
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
    param($path)
    if (Test-Path $path) {
        [xml]$xmlConfig = Get-Content -Path $path -Raw

        if ($xmlConfig.Configuration.VGpu) {
            $checkVGpu.Checked = $true
            $comboVGpu.Text = $xmlConfig.Configuration.VGpu
        }

        if ($xmlConfig.Configuration.MappedFolders) {
            $mappedFolder = $xmlConfig.Configuration.MappedFolders.MappedFolder
            if ($mappedFolder) {
                $listBoxMappedFolders.Items.Clear()
                foreach ($folder in $mappedFolder) {
                    $hostFolder = $folder.HostFolder
                    $readOnly = $folder.ReadOnly
                    $listBoxMappedFolders.Items.Add("$hostFolder | ReadOnly: $readOnly")
                }
                $checkMappedFolders.Checked = $true
            }
        }

        if ($xmlConfig.Configuration.LogonCommand) {
            $checkLogonCommand.Checked = $true
            $logonCommands = $xmlConfig.Configuration.LogonCommand.Command
            if ($logonCommands) {
                $listBoxLogonCommands.Items.Clear()
                foreach ($command in $logonCommands) {
                    $listBoxLogonCommands.Items.Add($command)
                }
            }
        }

        if ($xmlConfig.Configuration.Networking) {
            $checkNetworking.Checked = $true
            $comboNetworking.Text = $xmlConfig.Configuration.Networking
        }

        if ($xmlConfig.Configuration.AudioInput) {
            $checkAudioInput.Checked = $true
            $comboAudioInput.Text = $xmlConfig.Configuration.AudioInput
        }

        if ($xmlConfig.Configuration.VideoInput) {
            $checkVideoInput.Checked = $true
            $comboVideoInput.Text = $xmlConfig.Configuration.VideoInput
        }

        if ($xmlConfig.Configuration.ClipboardRedirection) {
            $checkClipboardRedirection.Checked = $true
            $comboClipboardRedirection.Text = $xmlConfig.Configuration.ClipboardRedirection
        }

        if ($xmlConfig.Configuration.PrinterRedirection) {
            $checkPrinterRedirection.Checked = $true
            $comboPrinterRedirection.Text = $xmlConfig.Configuration.PrinterRedirection
        }

        if ($xmlConfig.Configuration.ProtectedClient) {
            $checkProtectedClient.Checked = $true
            $comboProtectedClient.Text = $xmlConfig.Configuration.ProtectedClient
        }

        if ($xmlConfig.Configuration.MemoryInMB) {
            $checkMemoryInMB.Checked = $true
            $numericMemoryInMB.Value = [int]$xmlConfig.Configuration.MemoryInMB
        }

        if ($xmlConfig.Configuration.ExposeClipboard) {
            $checkExposeClipboard.Checked = $true
            $comboExposeClipboard.Text = $xmlConfig.Configuration.ExposeClipboard
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Configuration file not found!", "Error")
    }
}

function Update-UI {
    $sandboxInstalled = (Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM").State -eq "Enabled"
    $startButton.Enabled = $sandboxInstalled
    $installButton.Visible = -not $sandboxInstalled
}

# Create the main form
$form = New-Form

# Create TabControl and TabPages
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(780, 500)
$tabControl.Location = New-Object System.Drawing.Point(10, 10)

# Create Tabs
$tabHome = New-Object System.Windows.Forms.TabPage
$tabHome.Text = "Home"

$tabSettings = New-Object System.Windows.Forms.TabPage
$tabSettings.Text = "Settings"

$tabMappedFolders = New-Object System.Windows.Forms.TabPage
$tabMappedFolders.Text = "Mapped Folders"

$tabLogonCommand = New-Object System.Windows.Forms.TabPage
$tabLogonCommand.Text = "Logon Command"

$tabAbout = New-Object System.Windows.Forms.TabPage
$tabAbout.Text = "About"

# Add tabs to TabControl
$tabControl.TabPages.AddRange(@($tabHome, $tabSettings, $tabMappedFolders, $tabLogonCommand, $tabAbout))

# Create buttons and controls for Home tab
$saveButton = New-Button "Save Config" 20 20 {
    $saveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $saveFileDialog.Filter = "WSB files (*.wsb)|*.wsb"
    $saveFileDialog.ShowDialog() | Out-Null
    if ($saveFileDialog.FileName -ne "") {
        $wsbContent = "<Configuration>`r`n"

        if ($checkMappedFolders.Checked) {
            $wsbContent += "  <MappedFolders>`r`n"
            foreach ($item in $listBoxMappedFolders.Items) {
                $folderData = $item -split '\s*\|\s*'
                $wsbContent += "    <MappedFolder>`r`n"
                $wsbContent += "      <HostFolder>" + $folderData[0] + "</HostFolder>`r`n"
                $wsbContent += "      <ReadOnly>" + ($folderData[1] -replace 'ReadOnly:\s*') + "</ReadOnly>`r`n"
                $wsbContent += "    </MappedFolder>`r`n"
            }
            $wsbContent += "  </MappedFolders>`r`n"
        }

        if ($checkLogonCommand.Checked) {
            $wsbContent += "  <LogonCommand>`r`n"
            foreach ($item in $listBoxLogonCommands.Items) {
                $wsbContent += "    <Command>" + $item + "</Command>`r`n"
            }
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

        Save-Config -path $saveFileDialog.FileName -content $wsbContent
    }
}

$openButton = New-Button "Open Config" 200 20 {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "WSB files (*.wsb)|*.wsb"
    $openFileDialog.ShowDialog() | Out-Null
    if ($openFileDialog.FileName -ne "") {
        Get-SandboxConfiguration -path $openFileDialog.FileName
    }
}

$installButton = New-Button "Install Sandbox" 380 20 {
    Install-Sandbox
}

$startButton = New-Button "Start Sandbox" 540 20 {
    $openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $openFileDialog.Filter = "WSB files (*.wsb)|*.wsb"
    $openFileDialog.ShowDialog() | Out-Null
    if ($openFileDialog.FileName -ne "") {
        Start-Sandbox -configPath $openFileDialog.FileName
    }
}
$startButton.Enabled = $false

# Add buttons to Home tab
$tabHome.Controls.AddRange(@($saveButton, $openButton, $installButton, $startButton))

# Create controls for Settings tab
$checkNetworking = New-CheckBox "Networking" 20 20
$comboNetworking = New-Object System.Windows.Forms.ComboBox
$comboNetworking.Size = New-Object System.Drawing.Size(150, 30)
$comboNetworking.Location = New-Object System.Drawing.Point(180, 20)
$comboNetworking.Items.AddRange(@("Default", "Custom"))

$checkVGpu = New-CheckBox "VGpu" 20 60
$comboVGpu = New-Object System.Windows.Forms.ComboBox
$comboVGpu.Size = New-Object System.Drawing.Size(150, 30)
$comboVGpu.Location = New-Object System.Drawing.Point(180, 60)
$comboVGpu.Items.AddRange(@("None", "Virtual", "Direct"))

$checkAudioInput = New-CheckBox "Audio Input" 20 100
$comboAudioInput = New-Object System.Windows.Forms.ComboBox
$comboAudioInput.Size = New-Object System.Drawing.Size(150, 30)
$comboAudioInput.Location = New-Object System.Drawing.Point(180, 100)
$comboAudioInput.Items.AddRange(@("None", "Default", "Custom"))

$checkVideoInput = New-CheckBox "Video Input" 20 140
$comboVideoInput = New-Object System.Windows.Forms.ComboBox
$comboVideoInput.Size = New-Object System.Drawing.Size(150, 30)
$comboVideoInput.Location = New-Object System.Drawing.Point(180, 140)
$comboVideoInput.Items.AddRange(@("None", "Default", "Custom"))

$checkClipboardRedirection = New-CheckBox "Clipboard Redirection" 20 180
$comboClipboardRedirection = New-Object System.Windows.Forms.ComboBox
$comboClipboardRedirection.Size = New-Object System.Drawing.Size(150, 30)
$comboClipboardRedirection.Location = New-Object System.Drawing.Point(180, 180)
$comboClipboardRedirection.Items.AddRange(@("None", "Enabled", "Disabled"))

$checkPrinterRedirection = New-CheckBox "Printer Redirection" 20 220
$comboPrinterRedirection = New-Object System.Windows.Forms.ComboBox
$comboPrinterRedirection.Size = New-Object System.Drawing.Size(150, 30)
$comboPrinterRedirection.Location = New-Object System.Drawing.Point(180, 220)
$comboPrinterRedirection.Items.AddRange(@("None", "Enabled", "Disabled"))

$checkProtectedClient = New-CheckBox "Protected Client" 20 260
$comboProtectedClient = New-Object System.Windows.Forms.ComboBox
$comboProtectedClient.Size = New-Object System.Drawing.Size(150, 30)
$comboProtectedClient.Location = New-Object System.Drawing.Point(180, 260)
$comboProtectedClient.Items.AddRange(@("None", "Enabled", "Disabled"))

$checkMemoryInMB = New-CheckBox "Memory (MB)" 20 300
$numericMemoryInMB = New-Object System.Windows.Forms.NumericUpDown
$numericMemoryInMB.Size = New-Object System.Drawing.Size(150, 30)
$numericMemoryInMB.Location = New-Object System.Drawing.Point(180, 300)
$numericMemoryInMB.Minimum = 512
$numericMemoryInMB.Maximum = 16384
$numericMemoryInMB.Increment = 512

$checkExposeClipboard = New-CheckBox "Expose Clipboard" 20 340
$comboExposeClipboard = New-Object System.Windows.Forms.ComboBox
$comboExposeClipboard.Size = New-Object System.Drawing.Size(150, 30)
$comboExposeClipboard.Location = New-Object System.Drawing.Point(180, 340)
$comboExposeClipboard.Items.AddRange(@("None", "Enabled"))

# Add controls to Settings tab
$tabSettings.Controls.AddRange(@($checkNetworking, $comboNetworking, $checkVGpu, $comboVGpu, $checkAudioInput, $comboAudioInput, $checkVideoInput, $comboVideoInput, $checkClipboardRedirection, $comboClipboardRedirection, $checkPrinterRedirection, $comboPrinterRedirection, $checkProtectedClient, $comboProtectedClient, $checkMemoryInMB, $numericMemoryInMB, $checkExposeClipboard, $comboExposeClipboard))

# Create controls for Mapped Folders tab
$listBoxMappedFolders = New-ListBox 20 20 720 300
$buttonAddMappedFolder = New-Button "Add" 20 340 {
    $folderBrowserDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowserDialog.ShowDialog() | Out-Null
    if ($folderBrowserDialog.SelectedPath) {
        $listBoxMappedFolders.Items.Add("$($folderBrowserDialog.SelectedPath) | ReadOnly: $($checkReadOnly.Checked)")
    }
}
$buttonRemoveMappedFolder = New-Button "Remove" 100 340 {
    if ($listBoxMappedFolders.SelectedItem) {
        $listBoxMappedFolders.Items.Remove($listBoxMappedFolders.SelectedItem)
    }
}
$checkMappedFolders = New-CheckBox "Enable Mapped Folders" 20 380
$checkReadOnly = New-CheckBox "Read-Only" 180 380

# Add controls to Mapped Folders tab
$tabMappedFolders.Controls.AddRange(@($listBoxMappedFolders, $buttonAddMappedFolder, $buttonRemoveMappedFolder, $checkMappedFolders, $checkReadOnly))

# Create controls for Logon Command tab
$listBoxLogonCommands = New-ListBox 20 20 720 300
$textBoxLogonCommand = New-TextBox 20 340 580 30
$buttonAddLogonCommand = New-Button "Add" 620 340 {
    if ($textBoxLogonCommand.Text) {
        $listBoxLogonCommands.Items.Add($textBoxLogonCommand.Text)
        $textBoxLogonCommand.Clear()
    }
}
$buttonRemoveLogonCommand = New-Button "Remove" 680 340 {
    if ($listBoxLogonCommands.SelectedItem) {
        $listBoxLogonCommands.Items.Remove($listBoxLogonCommands.SelectedItem)
    }
}
$checkLogonCommand = New-CheckBox "Enable Logon Command" 20 380

# Add controls to Logon Command tab
$tabLogonCommand.Controls.AddRange(@($listBoxLogonCommands, $textBoxLogonCommand, $buttonAddLogonCommand, $buttonRemoveLogonCommand, $checkLogonCommand))

# About tab content
$aboutLabel = New-Object System.Windows.Forms.Label
$aboutLabel.Text = "Windows Sandbox Configurator v1.4`r`nBy Mickaël CHAVE"
$aboutLabel.Size = New-Object System.Drawing.Size(780, 100)
$aboutLabel.Location = New-Object System.Drawing.Point(20, 20)
$tabAbout.Controls.Add($aboutLabel)

# Update UI state
Update-UI

# Add TabControl to Form
$form.Controls.Add($tabControl)

# Show the form
[void]$form.ShowDialog()