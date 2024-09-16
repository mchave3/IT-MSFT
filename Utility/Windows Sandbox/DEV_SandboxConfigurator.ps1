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
                    <DataGrid Grid.Row="0" Grid.RowSpan="2" Grid.Column="0" />
                    <StackPanel Orientation="Vertical" HorizontalAlignment="Right" VerticalAlignment="Center" Grid.Column="1">
                        <Button Name="Home_Button_InstallWSB" Content="Install Windows Sandbox" Margin="5" Padding="5" IsEnabled="false"/>
                        <Separator Margin="5"/>
                        <Button Name="Home_Button_Open" Content="Open" Margin="5" />
                        <Button Name="Home_Button_Save" Content="Save" Margin="5" />
                        <Separator Margin="5"/>
                        <Button Name="Home_Button_StartWSB" Content="Start Sandbox" Margin="5" IsEnabled="False"/>
                    </StackPanel>
                </Grid>
            </TabItem>
            <TabItem Header="Settings">
                <!-- Settings tab -->
                <Grid VerticalAlignment="Center" HorizontalAlignment="Center" Margin="5">
                    <StackPanel>
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
            <TabItem Header="Help" Visibility="Collapsed">
                <!-- Content for Help tab -->
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
    } else {
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
            Restart-Computer -Force -Timeout 60
        }
    } catch {
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
})

# Save button event
$Home_Button_Save.Add_Click({
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.Filter = "Sandbox Configuration Files (*.wsb)|*.wsb"
    $SaveFileDialog.Title = "Save Sandbox Configuration File"
    $SaveFileDialog.ShowDialog() | Out-Null
})

##############################################################################################
# Settings tab logic
##############################################################################################

# vGPU checkbox event
$Settings_Checkbox_vGPU.Add_Click({
    if ($Settings_Checkbox_vGPU.IsChecked) {
        $Settings_ComboBox_vGPU.IsEnabled = $true
    } else {
        $Settings_ComboBox_vGPU.IsEnabled = $false
        $Settings_ComboBox_vGPU.SelectedIndex = 2
    }
})

# vGPU combobox event
$Settings_ComboBox_vGPU.Add_SelectionChanged({
    write-host $Settings_ComboBox_vGPU.SelectedItem
})

##############################################################################################
# Main code
##############################################################################################

# Check if Windows Sandbox is installed
CheckWSBInstalled

# Show the window
$Window.ShowDialog() | Out-Null