<#
.SYNOPSIS
Windows Sandbox Configurator

.DESCRIPTION
This script provides a graphical user interface (GUI) for configuring and managing Windows Sandbox. It allows users to install Windows Sandbox, save and load sandbox configurations, and start the sandbox with a specific configuration file.

.NOTES
Author: Mickaël CHAVE
Date: 12/09/2024
Version: 1.0
#>

Clear-Host

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows Sandbox Configurator" 
        Height="450" Width="800" 
        ResizeMode="NoResize" 
        WindowStartupLocation="CenterScreen">
    <Grid>
        <TabControl>
            <TabItem Header="Home">
                <!-- Home tab -->
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*" />
                        <ColumnDefinition Width="Auto" />
                    </Grid.ColumnDefinitions>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>
                    <Grid Grid.Row="0" Grid.RowSpan="2" Grid.Column="0">
                        <Grid Height="Auto" HorizontalAlignment="Left" VerticalAlignment="Top">
                            <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top">
                                <Label Content="Configuration File:" Margin="5"/>
                                <TextBox Name="Home_TextBox_ConfigFile" Text="No Configuration File" Width="400" Margin="5" VerticalAlignment="Center" IsReadOnly="True"/>
                            </StackPanel>
                        </Grid>
                    </Grid>
                    <StackPanel Orientation="Vertical" HorizontalAlignment="Right" VerticalAlignment="Center" Grid.Column="1">
                        <Button Name="Home_Button_InstallWSB" Content="Install Windows Sandbox" Margin="5" Padding="5" IsEnabled="false"/>
                        <Separator Margin="5"/>
                        <Button Name="Home_Button_Open" Content="Open" Margin="5" />
                        <Button Name="Home_Button_Save" Content="Save" Margin="5" IsEnabled="False"/>
                        <Button Name="Home_Button_SaveAs" Content="Save As" Margin="5" />
                        <Button Name="Home_Button_Clear" Content="Clear" Margin="5" />
                        <Separator Margin="5"/>
                        <Button Name="Home_Button_StartWSB" Content="Start Sandbox" Margin="5" IsEnabled="False"/>
                    </StackPanel>
                </Grid>
            </TabItem>
            <TabItem Header="Settings">
                <!-- Settings tab -->
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>
                    <Grid Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Top">
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top">
                            <Label Content="Configuration File:" Margin="5"/>
                            <TextBox Name="Settings_TextBox_ConfigFile" Text="No Configuration File" Width="400" Margin="5" VerticalAlignment="Center" IsReadOnly="True"/>
                        </StackPanel>
                    </Grid>
                    <StackPanel Grid.Row="1" VerticalAlignment="Center">
                        <!-- vGPU -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_vGPU" Content="vGPU" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_vGPU" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- Networking -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_Networking" Content="Networking" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_Networking" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- Audio Input -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_AudioInput" Content="Audio Input" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_AudioInput" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- Video Input -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_VideoInput" Content="Video Input" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_VideoInput" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- Protected Client -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_ProtectedClient" Content="Protected Client" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_ProtectedClient" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- Printer Redirection -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_PrinterRedirection" Content="Printer Redirection" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_PrinterRedirection" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- Clipboard Redirection -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_ClipboardRedirection" Content="Clipboard Redirection" VerticalAlignment="Center" Width="150"/>
                            <ComboBox Name="Settings_ComboBox_ClipboardRedirection" IsEnabled="False" SelectedIndex="2" HorizontalContentAlignment="Center" Width="150">
                                <ComboBoxItem Content="Enable" />
                                <ComboBoxItem Content="Disable" />
                                <ComboBoxItem Content="Default" />
                            </ComboBox>
                        </StackPanel>
                        <!-- MemoryInMB -->
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="5">
                            <CheckBox Name="Settings_Checkbox_MemoryInMB" Content="Memory (MB)" VerticalAlignment="Center" Width="150"/>
                            <TextBox Name="Settings_TextBox_MemoryInMB" IsEnabled="False" Text="512" Width="150" HorizontalContentAlignment="Center"/>
                        </StackPanel>
                    </StackPanel>
                </Grid>
            </TabItem>
            <TabItem Header="Mapped Folders">
                <!-- Mapped Folders tab -->
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto" />
                        <RowDefinition Height="*" />
                    </Grid.RowDefinitions>
                    <Grid Grid.Row="0" HorizontalAlignment="Left" VerticalAlignment="Top">
                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Top">
                            <Label Content="Configuration File:" Margin="5"/>
                            <TextBox Name="MappedFolders_TextBox_ConfigFile" Text="No Configuration File" Width="400" Margin="5" VerticalAlignment="Center" IsReadOnly="True"/>
                        </StackPanel>
                    </Grid>
                    <StackPanel Grid.Row="1" VerticalAlignment="Center" Orientation="Horizontal">
                        <!-- +, -, ^, v buttons -->
                        <StackPanel Orientation="Vertical" HorizontalAlignment="Left" VerticalAlignment="Center" Margin="5">
                            <Button Content="+" Width="30" Height="30" Margin="5"/>
                            <Button Content="-" Width="30" Height="30" Margin="5"/>
                            <Button Content="^" Width="30" Height="30" Margin="5"/>
                            <Button Content="v" Width="30" Height="30" Margin="5"/>
                        </StackPanel>
                        <DataGrid Name="MappedFolders_DataGrid" AutoGenerateColumns="False" Margin="5">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="Host Folder" Binding="{Binding HostFolder}" Width="*" />
                                <DataGridTextColumn Header="Sandbox Folder" Binding="{Binding SandboxFolder}" Width="*" />
                            </DataGrid.Columns>
                        </DataGrid>
                    </StackPanel>
                </Grid>
            </TabItem>
            <TabItem Header="About">
                <TextBox Text="Windows Sandbox Configurator" IsReadOnly="True" FontSize="24" TextAlignment="Center" />
            </TabItem>
        </TabControl>
    </Grid>
</Window>
"@

# Load XAML
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$Window = [Windows.Markup.XamlReader]::Load($reader)

# Create variables for each named element in the XAML
$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name ($_.Name) -Value $Window.FindName($_.Name)
}

##############################################################################################
# Home tab logic
##############################################################################################

# Check if Windows Sandbox is installed
function CheckWSBInstalled {
    $WSBInstalled = Get-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" | Select-Object -ExpandProperty State
    if ($WSBInstalled -eq "Enabled") {
        $Home_Button_InstallWSB.IsEnabled = $false
        $Home_Button_StartWSB.IsEnabled = $true
    }
    else {
        $Home_Button_InstallWSB.IsEnabled = $true
        $Home_Button_StartWSB.IsEnabled = $false
    }
}

# Install Windows Sandbox button event
$Home_Button_InstallWSB.Add_Click({
        try {
            # Enable Windows Sandbox feature
            Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -All -NoRestart -ErrorAction Stop

            # Prompt user to restart the computer
            $restartPrompt = [System.Windows.Forms.MessageBox]::Show("You must restart your computer to apply the changes. Do you want to restart now?", "Restart Required", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Warning)
            if ($restartPrompt -eq [System.Windows.Forms.DialogResult]::Yes) {
                shutdown.exe /r /t 60
            }
        }
        catch {
            [System.Windows.Forms.MessageBox]::Show("An error occurred while enabling Windows Sandbox: $_", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }

        # Check if Windows Sandbox is installed
        CheckWSBInstalled
    })

# Start Sandbox button event
$Home_Button_StartWSB.Add_Click({
        Start-Process -FilePath "C:\Windows\System32\WindowsSandbox.exe"
    })

# Open button event
$Home_Button_Open.Add_Click({
        $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
        $OpenFileDialog.Filter = "Sandbox Configuration Files (*.wsb)|*.wsb"
        $OpenFileDialog.Title = "Open Sandbox Configuration File"
        $OpenFileDialog.ShowDialog() | Out-Null
    
        if ($OpenFileDialog.FileName -ne "") {
            Get-SandboxConfiguration -path $OpenFileDialog.FileName

            $Home_TextBox_ConfigFile.Text = $OpenFileDialog.FileName
            $Settings_TextBox_ConfigFile.Text = $OpenFileDialog.FileName

            $Home_Button_Save.IsEnabled = $true
        }
    })

# Save button event
$Home_Button_Save.Add_Click({
        if ($Home_TextBox_ConfigFile.Text -eq "No Configuration File") {
            [System.Windows.Forms.MessageBox]::Show("Please open a configuration file before saving.", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
        else {
            $wsbContent = Save-SandboxConfiguration -path $Home_TextBox_ConfigFile.Text
            $wsbContent | Out-File -FilePath $Home_TextBox_ConfigFile.Text -Encoding utf8

            [System.Windows.Forms.MessageBox]::Show("Configuration file saved successfully.", "Success", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
    })

# Save As button event
$Home_Button_SaveAs.Add_Click({
        $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
        $SaveFileDialog.Filter = "Sandbox Configuration Files (*.wsb)|*.wsb"
        $SaveFileDialog.Title = "Save Sandbox Configuration File"
        $SaveFileDialog.ShowDialog() | Out-Null

        if ($SaveFileDialog.FileName -ne "") {
            $wsbContent = Save-SandboxConfiguration -path $SaveFileDialog.FileName
            $wsbContent | Out-File -FilePath $SaveFileDialog.FileName -Encoding utf8

            $Home_TextBox_ConfigFile.Text = $SaveFileDialog.FileName
            $Settings_TextBox_ConfigFile.Text = $SaveFileDialog.FileName

            $Home_Button_Save.IsEnabled = $true
        }
    })

# Clear button event
$Home_Button_Clear.Add_Click({
        $Home_TextBox_ConfigFile.Text = "No Configuration File"
        $Settings_TextBox_ConfigFile.Text = "No Configuration File"

        # Reset all settings
        foreach ($control in $Window.FindName("Settings_Grid").Children) {
            if ($control.GetType().Name -eq "StackPanel") {
                $control.Children[0].IsChecked = $false
                $control.Children[1].IsEnabled = $false
                $control.Children[1].SelectedIndex = 2
            }
        }

        $Settings_TextBox_MemoryInMB.IsEnabled = $false
        $Settings_TextBox_MemoryInMB.Text = "512"
    })

##############################################################################################
# Settings tab logic
##############################################################################################

# Generic checkbox event handler
function Set-CheckboxEvent {
    param (
        [System.Windows.Controls.CheckBox]$checkbox,
        [System.Windows.Controls.Control]$control,
        [int]$defaultIndex = 2,
        [string]$defaultText = "512"
    )

    if ($checkbox.IsChecked) {
        $control.IsEnabled = $true
    }
    else {
        $control.IsEnabled = $false
        if ($control -is [System.Windows.Controls.ComboBox]) {
            $control.SelectedIndex = $defaultIndex
        }
        elseif ($control -is [System.Windows.Controls.TextBox]) {
            $control.Text = $defaultText
        }
    }
}

# vGPU checkbox event
$Settings_Checkbox_vGPU.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_vGPU -control $Settings_ComboBox_vGPU
    })

# Networking checkbox event
$Settings_Checkbox_Networking.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_Networking -control $Settings_ComboBox_Networking
    })

# Audio Input checkbox event
$Settings_Checkbox_AudioInput.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_AudioInput -control $Settings_ComboBox_AudioInput
    })

# Video Input checkbox event
$Settings_Checkbox_VideoInput.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_VideoInput -control $Settings_ComboBox_VideoInput
    })

# Protected Client checkbox event
$Settings_Checkbox_ProtectedClient.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_ProtectedClient -control $Settings_ComboBox_ProtectedClient
    })

# Printer Redirection checkbox event
$Settings_Checkbox_PrinterRedirection.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_PrinterRedirection -control $Settings_ComboBox_PrinterRedirection
    })

# Clipboard Redirection checkbox event
$Settings_Checkbox_ClipboardRedirection.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_ClipboardRedirection -control $Settings_ComboBox_ClipboardRedirection
    })

# MemoryInMB checkbox event
$Settings_Checkbox_MemoryInMB.Add_Click({
        Set-CheckboxEvent -checkbox $Settings_Checkbox_MemoryInMB -control $Settings_TextBox_MemoryInMB -defaultText "512"
    })

##############################################################################################
# Main code
##############################################################################################

# Function to handle switch logic for ComboBox
function Set-ComboBoxSelection {
    param (
        [string]$value,
        [System.Windows.Controls.ComboBox]$comboBox
    )

    switch ($value) {
        "Enable" { $comboBox.SelectedIndex = 0 }
        "Disable" { $comboBox.SelectedIndex = 1 }
        "Default" { $comboBox.SelectedIndex = 2 }
    }
}

# Get sandbox configuration
function Get-SandboxConfiguration {
    param (
        [string]$path
    )

    [xml]$xmlConfig = Get-Content -Path $path -Raw

    # vGPU
    if ($xmlConfig.Configuration.VGpu) {
        $Settings_Checkbox_vGPU.IsChecked = $true
        $Settings_ComboBox_vGPU.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.VGpu -comboBox $Settings_ComboBox_vGPU
    }
    else {
        $Settings_Checkbox_vGPU.IsChecked = $false
        $Settings_ComboBox_vGPU.IsEnabled = $false
        $Settings_ComboBox_vGPU.SelectedIndex = 2
    }

    # Networking
    if ($xmlConfig.Configuration.Networking) {
        $Settings_Checkbox_Networking.IsChecked = $true
        $Settings_ComboBox_Networking.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.Networking -comboBox $Settings_ComboBox_Networking
    }
    else {
        $Settings_Checkbox_Networking.IsChecked = $false
        $Settings_ComboBox_Networking.IsEnabled = $false
        $Settings_ComboBox_Networking.SelectedIndex = 2
    }

    # Audio Input
    if ($xmlConfig.Configuration.AudioInput) {
        $Settings_Checkbox_AudioInput.IsChecked = $true
        $Settings_ComboBox_AudioInput.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.AudioInput -comboBox $Settings_ComboBox_AudioInput
    }
    else {
        $Settings_Checkbox_AudioInput.IsChecked = $false
        $Settings_ComboBox_AudioInput.IsEnabled = $false
        $Settings_ComboBox_AudioInput.SelectedIndex = 2
    }

    # Video Input
    if ($xmlConfig.Configuration.VideoInput) {
        $Settings_Checkbox_VideoInput.IsChecked = $true
        $Settings_ComboBox_VideoInput.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.VideoInput -comboBox $Settings_ComboBox_VideoInput
    }
    else {
        $Settings_Checkbox_VideoInput.IsChecked = $false
        $Settings_ComboBox_VideoInput.IsEnabled = $false
        $Settings_ComboBox_VideoInput.SelectedIndex = 2
    }

    # Protected Client
    if ($xmlConfig.Configuration.ProtectedClient) {
        $Settings_Checkbox_ProtectedClient.IsChecked = $true
        $Settings_ComboBox_ProtectedClient.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.ProtectedClient -comboBox $Settings_ComboBox_ProtectedClient
    }
    else {
        $Settings_Checkbox_ProtectedClient.IsChecked = $false
        $Settings_ComboBox_ProtectedClient.IsEnabled = $false
        $Settings_ComboBox_ProtectedClient.SelectedIndex = 2
    }

    # Printer Redirection
    if ($xmlConfig.Configuration.PrinterRedirection) {
        $Settings_Checkbox_PrinterRedirection.IsChecked = $true
        $Settings_ComboBox_PrinterRedirection.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.PrinterRedirection -comboBox $Settings_ComboBox_PrinterRedirection
    }
    else {
        $Settings_Checkbox_PrinterRedirection.IsChecked = $false
        $Settings_ComboBox_PrinterRedirection.IsEnabled = $false
        $Settings_ComboBox_PrinterRedirection.SelectedIndex = 2
    }

    # Clipboard Redirection
    if ($xmlConfig.Configuration.ClipboardRedirection) {
        $Settings_Checkbox_ClipboardRedirection.IsChecked = $true
        $Settings_ComboBox_ClipboardRedirection.IsEnabled = $true
        Set-ComboBoxSelection -value $xmlConfig.Configuration.ClipboardRedirection -comboBox $Settings_ComboBox_ClipboardRedirection
    }
    else {
        $Settings_Checkbox_ClipboardRedirection.IsChecked = $false
        $Settings_ComboBox_ClipboardRedirection.IsEnabled = $false
        $Settings_ComboBox_ClipboardRedirection.SelectedIndex = 2
    }

    # MemoryInMB
    if ($xmlConfig.Configuration.MemoryInMB) {
        $Settings_Checkbox_MemoryInMB.IsChecked = $true
        $Settings_TextBox_MemoryInMB.IsEnabled = $true
        $Settings_TextBox_MemoryInMB.Text = $xmlConfig.Configuration.MemoryInMB
    }
    else {
        $Settings_Checkbox_MemoryInMB.IsChecked = $false
        $Settings_TextBox_MemoryInMB.IsEnabled = $false
        $Settings_TextBox_MemoryInMB.Text = "512"
    }
}

# Function to save sandbox configuration to file
function Save-SandboxConfiguration {
    param (
        [string]$path
    )

    $wsbContent = "<Configuration>`r`n"

    # vGPU
    if ($Settings_Checkbox_vGPU.IsChecked) {
        $wsbContent += "    <VGpu>$($Settings_ComboBox_vGPU.Text)</VGpu>`r`n"
    }
    # Networking
    if ($Settings_Checkbox_Networking.IsChecked) {
        $wsbContent += "    <Networking>$($Settings_ComboBox_Networking.Text)</Networking>`r`n"
    }
    # Audio Input
    if ($Settings_Checkbox_AudioInput.IsChecked) {
        $wsbContent += "    <AudioInput>$($Settings_ComboBox_AudioInput.Text)</AudioInput>`r`n"
    }
    # Video Input
    if ($Settings_Checkbox_VideoInput.IsChecked) {
        $wsbContent += "    <VideoInput>$($Settings_ComboBox_VideoInput.Text)</VideoInput>`r`n"
    }
    # Protected Client
    if ($Settings_Checkbox_ProtectedClient.IsChecked) {
        $wsbContent += "    <ProtectedClient>$($Settings_ComboBox_ProtectedClient.Text)</ProtectedClient>`r`n"
    }
    # Printer Redirection
    if ($Settings_Checkbox_PrinterRedirection.IsChecked) {
        $wsbContent += "    <PrinterRedirection>$($Settings_ComboBox_PrinterRedirection.Text)</PrinterRedirection>`r`n"
    }
    # Clipboard Redirection
    if ($Settings_Checkbox_ClipboardRedirection.IsChecked) {
        $wsbContent += "    <ClipboardRedirection>$($Settings_ComboBox_ClipboardRedirection.Text)</ClipboardRedirection>`r`n"
    }
    # MemoryInMB
    if ($Settings_Checkbox_MemoryInMB.IsChecked) {
        $wsbContent += "    <MemoryInMB>$($Settings_TextBox_MemoryInMB.Text)</MemoryInMB>`r`n"
    }

    $wsbContent += "</Configuration>"

    return $wsbContent
}


# Check if Windows Sandbox is installed
CheckWSBInstalled

# Show the window
$Window.ShowDialog() | Out-Null