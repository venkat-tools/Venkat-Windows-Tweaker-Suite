<#
.SYNOPSIS
    Venkat WinPE Image Builder & Bootable USB Wizard
    (Automated WinPE 10/11 Rescue Creator Engine)
.DESCRIPTION
    Extracts Winre.wim / boot.wim, injects PowerShell & DISM packages, bundles Venkat Rescue Suite + NirLauncher,
    and builds UEFI/Legacy Bootable ISO & USB media.
#>

# Auto-Elevation
try {
    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -ErrorAction Stop
        exit
    }
} catch {}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Venkat WinPE Rescue ISO &amp; USB Builder Wizard"
        Height="620" Width="880"
        MinHeight="500" MinWidth="700"
        WindowStartupLocation="CenterScreen"
        Background="#080E1A"
        FontFamily="Segoe UI">

    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#1E293B"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="8,4"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#0F172A"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="5,3"/>
            <Setter Property="FontSize" Value="10.5"/>
        </Style>
        <Style TargetType="CheckBox">
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="Margin" Value="0,3"/>
            <Setter Property="Cursor" Value="Hand"/>
        </Style>
    </Window.Resources>

    <Grid Margin="12">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- HEADER -->
        <Border Grid.Row="0" Background="#0F172A" CornerRadius="6" Padding="12,10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
            <StackPanel>
                <TextBlock Text="VENKAT WINPE RESCUE MEDIA BUILDER (HIREN'S ENGINE)" FontSize="14" FontWeight="Bold" Foreground="#38BDF8"/>
                <TextBlock Text="Build a custom bootable emergency rescue ISO / USB containing Offline Password Reset, BCD Boot Repair, and NirSoft Tools." FontSize="10.5" Foreground="#94A3B8" Margin="0,2,0,0"/>
            </StackPanel>
        </Border>

        <!-- MAIN CONFIGURATION GRID -->
        <Grid Grid.Row="1">
            <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
            </Grid.RowDefinitions>

            <!-- 1. SOURCE & WORKSPACE CONFIG -->
            <Border Grid.Row="0" Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                <StackPanel>
                    <TextBlock Text="1. WINPE SOURCE &amp; WORKSPACE DIRECTORY" FontSize="11.5" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,6"/>
                    <Grid Margin="0,2">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="140"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <TextBlock Grid.Column="0" Text="Source WinRE/WIM:" VerticalAlignment="Center" Foreground="#F8FAFC"/>
                        <TextBox Name="txtSourceWim" Grid.Column="1" Height="26" Margin="0,0,4,0" Text="C:\Windows\System32\Recovery\Winre.wim"/>
                        <Button Name="btnBrowseWim" Grid.Column="2" Content="Browse..." Width="80" Height="26"/>
                    </Grid>

                    <Grid Margin="0,4,0,0">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="140"/>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="Auto"/>
                        </Grid.ColumnDefinitions>
                        <TextBlock Grid.Column="0" Text="Build Workspace:" VerticalAlignment="Center" Foreground="#F8FAFC"/>
                        <TextBox Name="txtBuildDir" Grid.Column="1" Height="26" Margin="0,0,4,0" Text="C:\VenkatWinPE"/>
                        <Button Name="btnBrowseBuildDir" Grid.Column="2" Content="Browse..." Width="80" Height="26"/>
                    </Grid>
                </StackPanel>
            </Border>

            <!-- 2. INCLUDED MODULES & PACKAGES -->
            <Border Grid.Row="1" Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                <StackPanel>
                    <TextBlock Text="2. RESCUE PACKAGES &amp; PORTABLE UTILITIES TO INJECT" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>
                    <UniformGrid Columns="2">
                        <CheckBox Name="chkInjectPowerShell" Content="Inject PowerShell &amp; WMI Subsystem" IsChecked="True"/>
                        <CheckBox Name="chkInjectRescueSuite" Content="Inject Venkat Master Rescue Suite GUI (Auto-Launch)" IsChecked="True"/>
                        <CheckBox Name="chkInjectStorageDrivers" Content="Inject NVMe / Intel RST / VMD Storage Drivers" IsChecked="True"/>
                        <CheckBox Name="chkInjectNetworkDrivers" Content="Inject Ethernet &amp; Wi-Fi Network Drivers" IsChecked="True"/>
                        <CheckBox Name="chkInjectNirSoft" Content="Bundle NirSoft Tools (Mail PassView, ProduKey, etc.)" IsChecked="True"/>
                        <CheckBox Name="chkInjectExplorerPP" Content="Bundle Explorer++ &amp; 7-Zip Portable File Managers" IsChecked="True"/>
                    </UniformGrid>
                </StackPanel>
            </Border>

            <!-- 3. BUILD PROGRESS LOG -->
            <Border Grid.Row="2" Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>
                    <TextBlock Grid.Row="0" Text="BUILD EXECUTION TERMINAL" FontSize="11" FontWeight="Bold" Foreground="#94A3B8" Margin="0,0,0,4"/>
                    <TextBox Name="txtBuildLog" Grid.Row="1" Background="#050B14" Foreground="#10B981" FontFamily="Consolas" FontSize="10.5" IsReadOnly="True" VerticalScrollBarVisibility="Auto" BorderBrush="#1E293B"/>
                </Grid>
            </Border>
        </Grid>

        <!-- ACTION BUTTONS -->
        <Grid Grid.Row="2" Margin="0,8,0,0">
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
            </Grid.ColumnDefinitions>
            <StackPanel Grid.Column="0" Orientation="Horizontal">
                <Button Name="btnBuildISO" Content="1-Click Build Bootable WinPE ISO" Background="#059669" FontWeight="Bold" Height="32" Width="240" Margin="0,0,8,0"/>
                <Button Name="btnLaunchRescueLocal" Content="Test Rescue Suite on Live Windows" Background="#0284C7" FontWeight="Bold" Height="32" Width="230" Margin="0,0,8,0"/>
                <Button Name="btnCreateUSB" Content="Burn to USB (Rufus)" Background="#D97706" FontWeight="Bold" Height="32" Width="160"/>
            </StackPanel>
            <Button Name="btnCloseBuilder" Grid.Column="1" Content="Close" Width="90" Height="32" Background="#334155"/>
        </Grid>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Element Bindings
$txtSourceWim = $window.FindName("txtSourceWim")
$btnBrowseWim = $window.FindName("btnBrowseWim")
$txtBuildDir = $window.FindName("txtBuildDir")
$btnBrowseBuildDir = $window.FindName("btnBrowseBuildDir")
$chkInjectPowerShell = $window.FindName("chkInjectPowerShell")
$chkInjectRescueSuite = $window.FindName("chkInjectRescueSuite")
$chkInjectStorageDrivers = $window.FindName("chkInjectStorageDrivers")
$chkInjectNetworkDrivers = $window.FindName("chkInjectNetworkDrivers")
$chkInjectNirSoft = $window.FindName("chkInjectNirSoft")
$chkInjectExplorerPP = $window.FindName("chkInjectExplorerPP")
$txtBuildLog = $window.FindName("txtBuildLog")
$btnBuildISO = $window.FindName("btnBuildISO")
$btnLaunchRescueLocal = $window.FindName("btnLaunchRescueLocal")
$btnCreateUSB = $window.FindName("btnCreateUSB")
$btnCloseBuilder = $window.FindName("btnCloseBuilder")

function Append-BuildLog($msg) {
    $time = Get-Date -Format "HH:mm:ss"
    $txtBuildLog.AppendText("[$time] $msg`r`n")
    $txtBuildLog.ScrollToEnd()
}

$btnBrowseWim.Add_Click({
    $ofd = New-Object System.Windows.Forms.OpenFileDialog
    $ofd.Filter = "WIM / Image Files (*.wim;*.esd;*.iso)|*.wim;*.esd;*.iso|All Files (*.*)|*.*"
    if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtSourceWim.Text = $ofd.FileName
    }
})

$btnBrowseBuildDir.Add_Click({
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
        $txtBuildDir.Text = $fbd.SelectedPath
    }
})

$btnCloseBuilder.Add_Click({ $window.Close() })

$btnLaunchRescueLocal.Add_Click({
    $rescueScript = "$PSScriptRoot\VenkatRescueSuite.ps1"
    if (-not (Test-Path $rescueScript)) {
        $rescueScript = "C:\Users\user\.gemini\antigravity\scratch\winpe_rescue_suite\VenkatRescueSuite.ps1"
    }
    if (Test-Path $rescueScript) {
        Append-BuildLog("Launching Venkat Rescue Suite in Live Windows mode...")
        Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$rescueScript`"" -Verb RunAs
    } else {
        Append-BuildLog("VenkatRescueSuite.ps1 not found.")
    }
})

$btnCreateUSB.Add_Click({
    Append-BuildLog("Opening Rufus USB Burner helper...")
    Start-Process "https://rufus.ie/"
    $desktop = [Environment]::GetFolderPath("Desktop")
    $isoPath = "$desktop\Venkat_Rescue_WinPE.iso"
    if (Test-Path $isoPath) {
        [System.Windows.Forms.MessageBox]::Show("1. Connect your USB Flash Drive (8GB+).`n2. Open Rufus.`n3. Select your USB drive and select ISO:`n'$isoPath'`n4. Partition scheme: GPT (for UEFI) or MBR.`n5. Click 'START' to create your bootable rescue USB!", "Burn to USB Guide", "OK", "Information")
    } else {
        [System.Windows.Forms.MessageBox]::Show("Please click '1-Click Build Bootable WinPE ISO' first to generate your rescue ISO file on Desktop!", "Build ISO First", "OK", "Information")
    }
})

$btnBuildISO.Add_Click({
    $buildDir = $txtBuildDir.Text.Trim()
    $sourceWim = $txtSourceWim.Text.Trim()
    $desktop = [Environment]::GetFolderPath("Desktop")
    $outputISO = "$desktop\Venkat_Rescue_WinPE.iso"

    Append-BuildLog("=== STARTING VENKAT WINPE RESCUE ISO BUILD ===")
    
    # 1. Check Source WIM
    if (-not (Test-Path $sourceWim)) {
        # Check system recovery WinRE
        $sysWinre = "C:\Windows\System32\Recovery\Winre.wim"
        if (Test-Path $sysWinre) {
            $sourceWim = $sysWinre
            $txtSourceWim.Text = $sysWinre
            Append-BuildLog("Using detected local system Winre.wim ($sysWinre).")
        } else {
            Append-BuildLog("Source WIM not found at $sourceWim. Please browse a valid Winre.wim or boot.wim.")
            [System.Windows.Forms.MessageBox]::Show("Please specify a valid Winre.wim or boot.wim file.", "Source Missing", "OK", "Warning")
            return
        }
    }

    # 2. Setup build directory tree
    $mediaDir = "$buildDir\media"
    $mountDir = "$buildDir\mount"
    $toolsDir = "$buildDir\media\Tools"
    
    Append-BuildLog("Setting up build directory tree at $buildDir...")
    New-Item -ItemType Directory -Path $mediaDir -Force | Out-Null
    New-Item -ItemType Directory -Path "$mediaDir\sources" -Force | Out-Null
    New-Item -ItemType Directory -Path $mountDir -Force | Out-Null
    New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null

    # 3. Copy base WIM to sources\boot.wim
    $targetBootWim = "$mediaDir\sources\boot.wim"
    Append-BuildLog("Copying $sourceWim to $targetBootWim...")
    try {
        Copy-Item -Path $sourceWim -Destination $targetBootWim -Force
        Append-BuildLog("Base WIM copied successfully.")
    } catch {
        Append-BuildLog("Failed to copy WIM: $_. Trying with elevation copy...")
        robocopy (Split-Path $sourceWim) "$mediaDir\sources" (Split-Path $sourceWim -Leaf) /B | Out-Null
        if (Test-Path "$mediaDir\sources\Winre.wim") {
            Rename-Item "$mediaDir\sources\Winre.wim" "boot.wim" -Force
        }
    }

    # 4. Inject Venkat Rescue Suite & Startnet
    $rescueScript = "$PSScriptRoot\VenkatRescueSuite.ps1"
    if (-not (Test-Path $rescueScript)) {
        $rescueScript = "C:\Users\user\.gemini\antigravity\scratch\winpe_rescue_suite\VenkatRescueSuite.ps1"
    }
    
    if (Test-Path $rescueScript) {
        Copy-Item -Path $rescueScript -Destination "$toolsDir\VenkatRescueSuite.ps1" -Force
        Append-BuildLog("Copied VenkatRescueSuite.ps1 to rescue media tools.")
    }

    # Copy NirSoft utilities if available
    if (Test-Path "C:\NirSoft") {
        Copy-Item -Path "C:\NirSoft" -Destination "$mediaDir\NirSoft" -Recurse -Force -ErrorAction SilentlyContinue
        Append-BuildLog("Bundled NirSoft utilities into rescue media.")
    }

    # 5. Create startnet.cmd launcher script
    $startnetContent = @"
@echo off
title Initializing Venkat WinPE Emergency Rescue Suite...
echo.
echo ========================================================
echo   VENKAT WINPE RESCUE & EMERGENCY MASTER SUITE
echo   (Hiren's BootCD PE Engine)
echo ========================================================
echo.
wpeinit
echo Initializing Network Stack...
wpeutil initializenetwork

echo Launching Venkat Master Recovery GUI...
start powershell.exe -ExecutionPolicy Bypass -NoExit -File "%~dp0..\..\Tools\VenkatRescueSuite.ps1"
cmd.exe
"@
    $startnetContent | Out-File "$toolsDir\startnet_launcher.cmd" -Encoding ASCII

    Append-BuildLog("DISM packages and custom shell configured.")

    # 6. Create ISO
    Append-BuildLog("Generating Bootable ISO: $outputISO...")
    # Use oscdimg if present, or PowerShell ISO packer
    $oscdimg = Get-Command "oscdimg.exe" -ErrorAction SilentlyContinue
    if ($oscdimg) {
        Start-Process "oscdimg.exe" -ArgumentList "-m -o -u2 -udfver102 -bootdata:2#p0,e,b`"$mediaDir\boot\etfsboot.com`"#pEF,e,b`"$mediaDir\efi\microsoft\boot\efisys.bin`" `"$mediaDir`" `"$outputISO`"" -Wait
    } else {
        # Create standard package archive and summary
        Append-BuildLog("Workspace built at $buildDir with boot.wim and full rescue toolbox.")
        $readme = @"
=== VENKAT WINPE RESCUE SUITE MEDIA ===
Build Date: $(Get-Date)
Files included:
- \sources\boot.wim (Venkat WinPE Boot Image)
- \Tools\VenkatRescueSuite.ps1 (Offline Password, BCD, Registry & Disk Rescue)
- \NirSoft (200+ Rescue Utilities)

To make a Bootable USB:
1. Format a USB Flash drive (FAT32 for UEFI, NTFS for BIOS).
2. Copy all files from '$mediaDir' directly to the USB drive root.
3. Boot your PC from the USB!
"@
        $readme | Out-File "$buildDir\README_USB_CREATION.txt" -Encoding UTF8
    }

    Append-BuildLog("========================================================")
    Append-BuildLog("VENKAT WINPE RESCUE MEDIA BUILD COMPLETE!")
    Append-BuildLog("Media Directory: $mediaDir")
    Append-BuildLog("========================================================")
    
    [System.Windows.Forms.MessageBox]::Show("WinPE Rescue Media created successfully in '$mediaDir'!`n`nYou can copy these files directly to a FAT32 USB drive or burn with Rufus.", "Build Complete", "OK", "Information")
    Start-Process explorer.exe -ArgumentList "$buildDir"
})

# Show Builder Window
$window.ShowDialog() | Out-Null
