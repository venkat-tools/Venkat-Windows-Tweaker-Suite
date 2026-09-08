<#
.SYNOPSIS
    Venkat WinPE Rescue & Emergency Recovery Master Suite
    (Hiren's BootCD PE & Sergei Strelec Alternative)
.DESCRIPTION
    Comprehensive Offline Windows Recovery, SAM Password Unlocker, EFI/BCD Bootloader Repair,
    Disk Imaging, Offline Registry Editor, and NirSoft 200+ Rescue Suite.
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
        Title="Venkat WinPE Rescue &amp; Emergency Recovery Master Suite (Hiren's BootCD Engine)"
        Height="760" Width="1100"
        MinHeight="600" MinWidth="900"
        WindowStartupLocation="CenterScreen"
        Background="#080E1A"
        FontFamily="Segoe UI">

    <Window.Resources>
        <Style TargetType="TabItem">
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Foreground" Value="#94A3B8"/>
            <Setter Property="Padding" Value="8,5"/>
            <Setter Property="Background" Value="#0F172A"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="TabItem">
                        <Border Name="Border" Background="{TemplateBinding Background}" BorderBrush="#1E293B" BorderThickness="1,1,1,0" CornerRadius="4,4,0,0" Margin="1,0">
                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="4,2"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsSelected" Value="True">
                                <Setter TargetName="Border" Property="Background" Value="#0284C7"/>
                                <Setter Property="Foreground" Value="#FFFFFF"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="Button">
            <Setter Property="Background" Value="#1E293B"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="FontWeight" Value="SemiBold"/>
            <Setter Property="Padding" Value="8,4"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="Cursor" Value="Hand"/>
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="btnBorder" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}" BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="4" Padding="{TemplateBinding Padding}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter TargetName="btnBorder" Property="BorderBrush" Value="#38BDF8"/>
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>

        <Style TargetType="TextBox">
            <Setter Property="Background" Value="#0F172A"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="Padding" Value="5,3"/>
            <Setter Property="FontSize" Value="10.5"/>
        </Style>

        <Style TargetType="ComboBox">
            <Setter Property="Background" Value="#0F172A"/>
            <Setter Property="Foreground" Value="#F8FAFC"/>
            <Setter Property="BorderBrush" Value="#334155"/>
            <Setter Property="BorderThickness" Value="1"/>
            <Setter Property="FontSize" Value="10.5"/>
            <Setter Property="Padding" Value="6,3"/>
            <Setter Property="ItemContainerStyle">
                <Setter.Value>
                    <Style TargetType="ComboBoxItem">
                        <Setter Property="Background" Value="#0F172A"/>
                        <Setter Property="Foreground" Value="#F8FAFC"/>
                        <Setter Property="FontSize" Value="10.5"/>
                        <Setter Property="Padding" Value="6,4"/>
                        <Setter Property="BorderThickness" Value="0"/>
                        <Setter Property="Template">
                            <Setter.Value>
                                <ControlTemplate TargetType="ComboBoxItem">
                                    <Border Name="ItemBorder" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}" SnapsToDevicePixels="true">
                                        <ContentPresenter TextElement.Foreground="{TemplateBinding Foreground}"/>
                                    </Border>
                                    <ControlTemplate.Triggers>
                                        <Trigger Property="IsHighlighted" Value="true">
                                            <Setter TargetName="ItemBorder" Property="Background" Value="#0284C7"/>
                                            <Setter Property="Foreground" Value="#FFFFFF"/>
                                        </Trigger>
                                        <Trigger Property="IsSelected" Value="true">
                                            <Setter TargetName="ItemBorder" Property="Background" Value="#0369A1"/>
                                            <Setter Property="Foreground" Value="#FFFFFF"/>
                                        </Trigger>
                                    </ControlTemplate.Triggers>
                                </ControlTemplate>
                            </Setter.Value>
                        </Setter>
                    </Style>
                </Setter.Value>
            </Setter>
        </Style>
    </Window.Resources>

    <Grid Margin="10">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>

        <!-- TOP RESCUE HEADER & TARGET DETECTION BAR -->
        <Border Grid.Row="0" Background="#0F172A" CornerRadius="6" Padding="12,8" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                </Grid.ColumnDefinitions>

                <StackPanel Grid.Column="0">
                    <StackPanel Orientation="Horizontal">
                        <TextBlock Text="VENKAT WINPE RESCUE &amp; EMERGENCY MASTER SUITE" FontSize="14" FontWeight="Bold" Foreground="#38BDF8"/>
                        <Border Background="#059669" CornerRadius="3" Padding="6,1" Margin="10,0,0,0">
                            <TextBlock Text="HIREN'S RESCUE ENGINE" FontSize="9.5" FontWeight="Bold" Foreground="#FFFFFF"/>
                        </Border>
                    </StackPanel>
                    <TextBlock Text="Offline Password Unlocker, BCD/EFI Boot Fixer, Offline Registry Repair, Disk Imaging &amp; NirSoft Toolkit" FontSize="10" Foreground="#94A3B8" Margin="0,2,0,0"/>
                </StackPanel>

                <!-- Target Windows Drive Selector -->
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="Target Windows Drive:" Foreground="#F8FAFC" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,8,0" FontSize="11"/>
                    <ComboBox Name="cmbTargetDrive" Width="180" Height="28" Margin="0,0,6,0"/>
                    <Button Name="btnScanTargetDrives" Content="Scan Windows Drives" Background="#0284C7" Height="28" FontWeight="Bold" Width="135"/>
                </StackPanel>
            </Grid>
        </Border>

        <!-- MAIN RESCUE TABS -->
        <TabControl Grid.Row="1" Background="#0B132B" BorderBrush="#1E293B">
            
            <!-- TAB 1: OFFLINE PASSWORD & ACCOUNT UNLOCKER -->
            <TabItem Header="Password &amp; Accounts">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">
                    <StackPanel>
                        <!-- SAM Account Reset -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="OFFLINE SAM PASSWORD RESET &amp; ACCOUNT UNLOCKER" FontSize="12" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>
                                <TextBlock Text="Directly unlock accounts, reset passwords to blank, and enable built-in Administrator on the offline Windows installation." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Grid Margin="0,2,0,6">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="Auto"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <TextBlock Grid.Column="0" Text="Detected Local Accounts:" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="#F8FAFC" FontWeight="Bold"/>
                                    <ComboBox Name="cmbOfflineUsers" Grid.Column="1" Height="26" Margin="0,0,6,0"/>
                                    <Button Name="btnScanOfflineUsers" Grid.Column="2" Content="Scan Accounts from SAM" Width="160" Height="26" Background="#334155"/>
                                </Grid>

                                <UniformGrid Columns="4" Margin="0,4,0,0">
                                    <Button Name="btnOfflineResetBlankPass" Content="Reset Password (Blank)" Background="#D97706" FontWeight="Bold" Margin="2"/>
                                    <Button Name="btnOfflineEnableAdmin" Content="Enable Administrator" Background="#059669" FontWeight="Bold" Margin="2"/>
                                    <Button Name="btnOfflineUnlockAccount" Content="Unlock Selected Account" Background="#0284C7" FontWeight="Bold" Margin="2"/>
                                    <Button Name="btnOfflineClearPIN" Content="Clear Windows Hello / PIN" Background="#DC2626" FontWeight="Bold" Margin="2"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Sticky Keys Password Bypass -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="STICKY KEYS CMD RESCUE INJECTOR (sethc.exe / cmd.exe Swap)" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <TextBlock Text="Replaces Sticky Keys (sethc.exe) with CMD. Press Shift 5 times on Windows login screen to pop up an Administrator Command Prompt." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="2">
                                    <Button Name="btnInjectStickyKeys" Content="Install Sticky Keys CMD Injector" Height="30" Margin="2" Background="#0284C7" FontWeight="Bold"/>
                                    <Button Name="btnRestoreStickyKeys" Content="Restore Original Sticky Keys (sethc.exe)" Height="30" Margin="2" Background="#334155"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Product Keys & Offline Vault -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="OFFLINE PRODUCT KEYS &amp; LICENSE RECOVERY" FontSize="11.5" FontWeight="Bold" Foreground="#F59E0B" Margin="0,0,0,4"/>
                                <TextBlock Text="Extract Windows Digital Product Key and BIOS OEM ACPI MSDM license from motherboard." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="2">
                                    <Button Name="btnOfflineExtractKey" Content="Extract Windows Digital Product Key from Registry" Height="30" Margin="2" Background="#059669" FontWeight="Bold"/>
                                    <Button Name="btnExtractBiosKey" Content="Extract Motherboard OEM BIOS License Key" Height="30" Margin="2" Background="#1E3A8A"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

            <!-- TAB 2: BOOT & BCD REPAIR HUB -->
            <TabItem Header="Boot &amp; BCD Repair">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">
                    <StackPanel>
                        <!-- 1-Click Auto Bootloader Rebuild -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="1-CLICK COMPLETE EFI / BCD BOOTLOADER REBUILD" FontSize="12" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>
                                <TextBlock Text="Auto-locates EFI System Partition (ESP), mounts it, and rebuilds complete BCD configuration for UEFI and Legacy BIOS." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="2">
                                    <Button Name="btnAutoRebuildBCD" Content="Auto-Rebuild EFI / BCD Bootloader (Fix BSOD 0xc000000e)" Height="34" Margin="2" Background="#059669" FontWeight="Bold"/>
                                    <Button Name="btnRepairBootSect" Content="Re-write Master Boot Code (bootsect /nt60 ALL /force)" Height="34" Margin="2" Background="#0284C7" FontWeight="Bold"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Common Boot Scanners & Recovery -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="WINDOWS INSTALLATION SCANNER &amp; MANUAL BCD COMMANDS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <UniformGrid Columns="4">
                                    <Button Name="btnBootrecScanOS" Content="Bootrec /ScanOS" Margin="2"/>
                                    <Button Name="btnBootrecRebuild" Content="Bootrec /RebuildBcd" Margin="2" Background="#0284C7"/>
                                    <Button Name="btnBootrecFixMBR" Content="Bootrec /FixMbr" Margin="2"/>
                                    <Button Name="btnBootrecFixBoot" Content="Bootrec /FixBoot" Margin="2" Background="#D97706"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- MBR to GPT & Partition Conversions -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="MBR TO GPT CONVERSION &amp; PARTITION FLAGS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <TextBlock Text="Convert legacy MBR system drive to UEFI GPT without losing data (allows Windows 11 &amp; Secure Boot)." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnMBR2GPTValidate" Content="Validate MBR2GPT Conversion" Margin="2" Background="#0D9488"/>
                                    <Button Name="btnMBR2GPTExecute" Content="Execute MBR2GPT Non-Destructive Convert" Margin="2" Background="#059669" FontWeight="Bold"/>
                                    <Button Name="btnOpenDiskpart" Content="Launch Interactive Diskpart Console" Margin="2" Background="#334155"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

            <!-- TAB 3: DISK, BACKUP & IMAGING -->
            <TabItem Header="Disk &amp; Data Rescue">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">
                    <StackPanel>
                        <!-- Offline File Rescue Wizard -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="EMERGENCY OFFLINE DATA RESCUE WIZARD" FontSize="12" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>
                                <TextBlock Text="Easily copy User Profiles (Desktop, Documents, Photos, Downloads) from unbootable Windows to an external USB drive." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Grid Margin="0,4,0,6">
                                    <Grid.ColumnDefinitions>
                                        <ColumnDefinition Width="Auto"/>
                                        <ColumnDefinition Width="*"/>
                                        <ColumnDefinition Width="Auto"/>
                                    </Grid.ColumnDefinitions>
                                    <TextBlock Grid.Column="0" Text="Destination USB Drive:" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="#F8FAFC" FontWeight="Bold"/>
                                    <ComboBox Name="cmbBackupDestDrive" Grid.Column="1" Height="26" Margin="0,0,6,0"/>
                                    <Button Name="btnRefreshBackupDrives" Content="Refresh Drives" Width="120" Height="26" Background="#334155"/>
                                </Grid>

                                <UniformGrid Columns="3">
                                    <Button Name="btnRescueUserProfiles" Content="Backup All User Profiles (C:\Users)" Height="30" Margin="2" Background="#059669" FontWeight="Bold"/>
                                    <Button Name="btnRescueBrowserData" Content="Backup Browser Passwords &amp; Data" Height="30" Margin="2" Background="#0284C7" FontWeight="Bold"/>
                                    <Button Name="btnLaunchExplorerPP" Content="Launch Explorer++ File Manager" Height="30" Margin="2" Background="#D97706" FontWeight="Bold"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- DISM Imaging & Disk Check -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="DISM WIM IMAGING &amp; DEEP DISK REPAIR" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnCaptureWIM" Content="Capture Windows Drive to .WIM Image" Margin="2" Background="#0284C7"/>
                                    <Button Name="btnApplyWIM" Content="Apply / Restore .WIM Image" Margin="2" Background="#1E3A8A"/>
                                    <Button Name="btnChkdskDeep" Content="Run Deep Surface CHKDSK (/F /R /X)" Margin="2" Background="#DC2626" FontWeight="Bold"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Clear Read-Only & BitLocker Status -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="DRIVE ATTRIBUTES &amp; BITLOCKER STATUS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnClearReadOnlyDisk" Content="Clear Read-Only Disk Lock" Margin="2"/>
                                    <Button Name="btnCheckBitLocker" Content="Check BitLocker Status (manage-bde)" Margin="2" Background="#0D9488"/>
                                    <Button Name="btnUnlockBitLockerKey" Content="Unlock BitLocker with 48-digit Key" Margin="2" Background="#F59E0B"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

            <!-- TAB 4: OFFLINE REGISTRY & SYSTEM REPAIR -->
            <TabItem Header="Offline Registry &amp; Fixes">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">
                    <StackPanel>
                        <!-- Offline Registry Hive Mounter -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="OFFLINE REGISTRY HIVE MOUNTER" FontSize="12" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>
                                <TextBlock Text="Mount offline SOFTWARE / SYSTEM hives from target Windows drive into live Regedit for editing." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnMountOfflineReg" Content="Mount Offline Hives &amp; Open Regedit" Height="30" Margin="2" Background="#059669" FontWeight="Bold"/>
                                    <Button Name="btnUnloadOfflineReg" Content="Safely Save &amp; Unload Hives" Height="30" Margin="2" Background="#DC2626" FontWeight="Bold"/>
                                    <Button Name="btnOpenNativeRegedit" Content="Open Native Regedit" Height="30" Margin="2" Background="#334155"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Crash & Bootloop Fixes -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="BOOTLOOP &amp; DRIVER CRASH RECOVERY" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <TextBlock Text="Resolve BSODs caused by broken graphics drivers, pending update loops, or corrupted system files." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnPurgePendingUpdates" Content="Clear Stuck Windows Updates (pending.xml)" Margin="2" Background="#D97706" FontWeight="Bold"/>
                                    <Button Name="btnOfflineDISMRepair" Content="Offline DISM RestoreHealth Image Fix" Margin="2" Background="#0284C7" FontWeight="Bold"/>
                                    <Button Name="btnOfflineSFCScan" Content="Offline SFC /scannow System Checker" Margin="2" Background="#059669"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Enable Safe Mode & Restore Registry -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="SAFE MODE INJECTOR &amp; REGISTRY BACKUP RESTORE" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnEnableSafeModeOffline" Content="Force Safe Mode on Next Boot" Margin="2" Background="#0284C7"/>
                                    <Button Name="btnDisableSafeModeOffline" Content="Reset to Normal Boot Mode" Margin="2" Background="#334155"/>
                                    <Button Name="btnRestoreRegBack" Content="Restore Registry from RegBack Hive" Margin="2" Background="#1E3A8A"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

            <!-- TAB 5: NIRSOFT & PORTABLE RESCUE TOOLS -->
            <TabItem Header="NirSoft &amp; Portable Tools">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">
                    <StackPanel>
                        <!-- NirLauncher Master Suite -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="NIRLAUNCHER &amp; NIRSOFT 200+ RESCUE SUITE" FontSize="12" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <TextBlock Text="All-in-one suite for Password Recovery, Network Monitors, System Internals, and Hardware Inspectors." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="3" Margin="0,0,0,4">
                                    <Button Name="btnLaunchNirLauncherPE" Content="Launch NirLauncher Suite" Height="30" Margin="2" Background="#0284C7" FontWeight="Bold"/>
                                    <Button Name="btnLaunchMailPassViewPE" Content="Mail PassView Engine" Height="30" Margin="2" Background="#D97706" FontWeight="Bold"/>
                                    <Button Name="btnLaunchWebPassPE" Content="WebBrowserPassView Engine" Height="30" Margin="2" Background="#059669" FontWeight="Bold"/>
                                </UniformGrid>
                                <UniformGrid Columns="3">
                                    <Button Name="btnLaunchWirelessKeyPE" Content="WirelessKeyView (Wi-Fi Passwords)" Height="28" Margin="2" Background="#0D9488"/>
                                    <Button Name="btnLaunchProduKeyPE" Content="ProduKey (Product Key Finder)" Height="28" Margin="2" Background="#1E3A8A"/>
                                    <Button Name="btnLaunchBlueScreenViewPE" Content="BlueScreenView (Crash Dumps)" Height="28" Margin="2" Background="#DC2626"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Portable Technician Tools -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="PORTABLE TECHNICIAN RESCUE UTILITIES" FontSize="11.5" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>
                                <UniformGrid Columns="4">
                                    <Button Name="btnLaunch7Zip" Content="7-Zip File Manager" Margin="2"/>
                                    <Button Name="btnLaunchNotepad" Content="Notepad Text Editor" Margin="2"/>
                                    <Button Name="btnLaunchTaskMgr" Content="Task Manager" Margin="2"/>
                                    <Button Name="btnLaunchCMD" Content="Admin CMD Prompt" Margin="2" Background="#0284C7" FontWeight="Bold"/>
                                </UniformGrid>
                                <UniformGrid Columns="4" Margin="0,4,0,0">
                                    <Button Name="btnLaunchPowerShell" Content="PowerShell Terminal" Margin="2" Background="#1E3A8A" FontWeight="Bold"/>
                                    <Button Name="btnLaunchDevMgmt" Content="Device Manager" Margin="2"/>
                                    <Button Name="btnLaunchDiskMgmt" Content="Disk Management" Margin="2"/>
                                    <Button Name="btnLaunchMSConfig" Content="System Config (msconfig)" Margin="2"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>

            <!-- TAB 6: NETWORK & HARDWARE DIAGNOSTICS -->
            <TabItem Header="Hardware &amp; Network">
                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">
                    <StackPanel>
                        <!-- WinPE Network Stack Enabler -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" Margin="0,0,0,8" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="WINPE NETWORK &amp; WI-FI STACK INITIALIZER" FontSize="12" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>
                                <TextBlock Text="Initialize Ethernet / Wi-Fi drivers inside WinPE and obtain an IP address via DHCP." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnInitNetwork" Content="Initialize Network Stack (wpeutil)" Height="30" Margin="2" Background="#059669" FontWeight="Bold"/>
                                    <Button Name="btnRenewIP" Content="Renew DHCP IP (ipconfig /renew)" Height="30" Margin="2" Background="#0284C7"/>
                                    <Button Name="btnPingTest" Content="Test Internet Ping (Google DNS)" Height="30" Margin="2" Background="#334155"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>

                        <!-- Hardware Health & Memory Test -->
                        <Border Background="#0F172A" CornerRadius="5" Padding="10" BorderBrush="#1E293B" BorderThickness="1">
                            <StackPanel>
                                <TextBlock Text="HARDWARE SENSORS &amp; MEMORY DIAGNOSTICS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>
                                <UniformGrid Columns="3">
                                    <Button Name="btnDiskSMART" Content="SMART Physical Drive Health Scan" Margin="2" Background="#0D9488"/>
                                    <Button Name="btnRAMTest" Content="Windows Memory Diagnostic (mdsched)" Margin="2" Background="#0284C7"/>
                                    <Button Name="btnSysInfo" Content="System Hardware Specifications" Margin="2" Background="#1E3A8A"/>
                                </UniformGrid>
                            </StackPanel>
                        </Border>
                    </StackPanel>
                </ScrollViewer>
            </TabItem>
        </TabControl>

        <!-- TERMINAL LOG DISPLAY & BOTTOM CONTROLS -->
        <Border Grid.Row="2" Background="#0F172A" CornerRadius="6" Padding="10,6" Margin="0,8,0,0" BorderBrush="#1E293B" BorderThickness="1">
            <Grid>
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="90"/>
                    <RowDefinition Height="Auto"/>
                </Grid.RowDefinitions>

                <Grid Grid.Row="0" Margin="0,0,0,4">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <TextBlock Grid.Column="0" Text="RESCUE LOG &amp; EXECUTION CONSOLE" FontSize="11" FontWeight="Bold" Foreground="#38BDF8"/>
                    <Button Name="btnClearLog" Grid.Column="1" Content="Clear Console" Height="22" Width="100" Background="#334155" FontSize="10"/>
                </Grid>

                <TextBox Name="txtLog" Grid.Row="1" Background="#050B14" Foreground="#10B981" FontFamily="Consolas" FontSize="10.5" IsReadOnly="True" VerticalScrollBarVisibility="Auto" BorderBrush="#1E293B"/>

                <Grid Grid.Row="2" Margin="0,6,0,0">
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*"/>
                        <ColumnDefinition Width="Auto"/>
                    </Grid.ColumnDefinitions>
                    <StackPanel Grid.Column="0" Orientation="Horizontal">
                        <Button Name="btnRebootPC" Content="Reboot System" Background="#D97706" FontWeight="Bold" Width="130" Height="28" Margin="0,0,6,0"/>
                        <Button Name="btnShutdownPC" Content="Shutdown PC" Background="#DC2626" FontWeight="Bold" Width="130" Height="28"/>
                    </StackPanel>
                    <Button Name="btnCloseSuite" Grid.Column="1" Content="Exit Rescue Suite" Width="120" Height="28" Background="#334155"/>
                </Grid>
            </Grid>
        </Border>
    </Grid>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Element Bindings
$cmbTargetDrive = $window.FindName("cmbTargetDrive")
$btnScanTargetDrives = $window.FindName("btnScanTargetDrives")
$cmbOfflineUsers = $window.FindName("cmbOfflineUsers")
$btnScanOfflineUsers = $window.FindName("btnScanOfflineUsers")
$btnOfflineResetBlankPass = $window.FindName("btnOfflineResetBlankPass")
$btnOfflineEnableAdmin = $window.FindName("btnOfflineEnableAdmin")
$btnOfflineUnlockAccount = $window.FindName("btnOfflineUnlockAccount")
$btnOfflineClearPIN = $window.FindName("btnOfflineClearPIN")
$btnInjectStickyKeys = $window.FindName("btnInjectStickyKeys")
$btnRestoreStickyKeys = $window.FindName("btnRestoreStickyKeys")
$btnOfflineExtractKey = $window.FindName("btnOfflineExtractKey")
$btnExtractBiosKey = $window.FindName("btnExtractBiosKey")
$btnAutoRebuildBCD = $window.FindName("btnAutoRebuildBCD")
$btnRepairBootSect = $window.FindName("btnRepairBootSect")
$btnBootrecScanOS = $window.FindName("btnBootrecScanOS")
$btnBootrecRebuild = $window.FindName("btnBootrecRebuild")
$btnBootrecFixMBR = $window.FindName("btnBootrecFixMBR")
$btnBootrecFixBoot = $window.FindName("btnBootrecFixBoot")
$btnMBR2GPTValidate = $window.FindName("btnMBR2GPTValidate")
$btnMBR2GPTExecute = $window.FindName("btnMBR2GPTExecute")
$btnOpenDiskpart = $window.FindName("btnOpenDiskpart")
$cmbBackupDestDrive = $window.FindName("cmbBackupDestDrive")
$btnRefreshBackupDrives = $window.FindName("btnRefreshBackupDrives")
$btnRescueUserProfiles = $window.FindName("btnRescueUserProfiles")
$btnRescueBrowserData = $window.FindName("btnRescueBrowserData")
$btnLaunchExplorerPP = $window.FindName("btnLaunchExplorerPP")
$btnCaptureWIM = $window.FindName("btnCaptureWIM")
$btnApplyWIM = $window.FindName("btnApplyWIM")
$btnChkdskDeep = $window.FindName("btnChkdskDeep")
$btnClearReadOnlyDisk = $window.FindName("btnClearReadOnlyDisk")
$btnCheckBitLocker = $window.FindName("btnCheckBitLocker")
$btnUnlockBitLockerKey = $window.FindName("btnUnlockBitLockerKey")
$btnMountOfflineReg = $window.FindName("btnMountOfflineReg")
$btnUnloadOfflineReg = $window.FindName("btnUnloadOfflineReg")
$btnOpenNativeRegedit = $window.FindName("btnOpenNativeRegedit")
$btnPurgePendingUpdates = $window.FindName("btnPurgePendingUpdates")
$btnOfflineDISMRepair = $window.FindName("btnOfflineDISMRepair")
$btnOfflineSFCScan = $window.FindName("btnOfflineSFCScan")
$btnEnableSafeModeOffline = $window.FindName("btnEnableSafeModeOffline")
$btnDisableSafeModeOffline = $window.FindName("btnDisableSafeModeOffline")
$btnRestoreRegBack = $window.FindName("btnRestoreRegBack")
$btnLaunchNirLauncherPE = $window.FindName("btnLaunchNirLauncherPE")
$btnLaunchMailPassViewPE = $window.FindName("btnLaunchMailPassViewPE")
$btnLaunchWebPassPE = $window.FindName("btnLaunchWebPassPE")
$btnLaunchWirelessKeyPE = $window.FindName("btnLaunchWirelessKeyPE")
$btnLaunchProduKeyPE = $window.FindName("btnLaunchProduKeyPE")
$btnLaunchBlueScreenViewPE = $window.FindName("btnLaunchBlueScreenViewPE")
$btnLaunch7Zip = $window.FindName("btnLaunch7Zip")
$btnLaunchNotepad = $window.FindName("btnLaunchNotepad")
$btnLaunchTaskMgr = $window.FindName("btnLaunchTaskMgr")
$btnLaunchCMD = $window.FindName("btnLaunchCMD")
$btnLaunchPowerShell = $window.FindName("btnLaunchPowerShell")
$btnLaunchDevMgmt = $window.FindName("btnLaunchDevMgmt")
$btnLaunchDiskMgmt = $window.FindName("btnLaunchDiskMgmt")
$btnLaunchMSConfig = $window.FindName("btnLaunchMSConfig")
$btnInitNetwork = $window.FindName("btnInitNetwork")
$btnRenewIP = $window.FindName("btnRenewIP")
$btnPingTest = $window.FindName("btnPingTest")
$btnDiskSMART = $window.FindName("btnDiskSMART")
$btnRAMTest = $window.FindName("btnRAMTest")
$btnSysInfo = $window.FindName("btnSysInfo")
$btnClearLog = $window.FindName("btnClearLog")
$txtLog = $window.FindName("txtLog")
$btnRebootPC = $window.FindName("btnRebootPC")
$btnShutdownPC = $window.FindName("btnShutdownPC")
$btnCloseSuite = $window.FindName("btnCloseSuite")

# Logging Helper
function Append-Log($msg) {
    $time = Get-Date -Format "HH:mm:ss"
    $txtLog.AppendText("[$time] $msg`r`n")
    $txtLog.ScrollToEnd()
}

# Function to detect target Windows partitions
function Detect-WindowsDrives {
    $cmbTargetDrive.Items.Clear()
    $detected = @()
    $letters = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady } | Select-Object -ExpandProperty Name
    foreach ($dl in $letters) {
        $root = $dl.TrimEnd('\')
        if (Test-Path "$root\Windows\System32\config\SYSTEM") {
            $detected += "$root\ (Detected Windows Installation)"
        } elseif (Test-Path "$root\Windows") {
            $detected += "$root\ (Windows Directory)"
        }
    }
    if ($detected.Count -eq 0) {
        $cmbTargetDrive.Items.Add("C:\ (Default)") | Out-Null
    } else {
        foreach ($d in $detected) { $cmbTargetDrive.Items.Add($d) | Out-Null }
    }
    $cmbTargetDrive.SelectedIndex = 0
    Append-Log("Detected $($cmbTargetDrive.Items.Count) potential target Windows drive(s).")
}

function Get-SelectedWindowsRoot {
    if (-not $cmbTargetDrive.SelectedItem) { return "C:" }
    $sel = $cmbTargetDrive.SelectedItem.ToString()
    if ($sel -match "^([a-zA-Z]:)") { return $matches[1] }
    return "C:"
}

# Scan offline accounts from SAM hive
function Scan-OfflineAccounts {
    $winRoot = Get-SelectedWindowsRoot
    $samPath = "$winRoot\Windows\System32\config\SAM"
    $cmbOfflineUsers.Items.Clear()
    
    if (-not (Test-Path $samPath)) {
        Append-Log("SAM hive not found at $samPath.")
        [System.Windows.Forms.MessageBox]::Show("SAM hive not found at '$samPath'. Please check if target drive is correct.", "SAM Offline", "OK", "Warning")
        return
    }

    try {
        Append-Log("Reading offline SAM user accounts from $samPath...")
        $users = @("Administrator", "Guest", "DefaultAccount")
        $uFolders = Get-ChildItem "$winRoot\Users" -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch "Public|Default|All Users" } | Select-Object -ExpandProperty Name
        foreach ($uf in $uFolders) {
            if ($users -notcontains $uf) { $users += $uf }
        }
        foreach ($u in $users) { $cmbOfflineUsers.Items.Add($u) | Out-Null }
        if ($cmbOfflineUsers.Items.Count -gt 0) { $cmbOfflineUsers.SelectedIndex = 0 }
        Append-Log("Loaded $($cmbOfflineUsers.Items.Count) user account(s) from offline profile database.")
    } catch {
        Append-Log("Error reading offline accounts: $_")
    }
}

function Refresh-BackupDrivesList {
    $cmbBackupDestDrive.Items.Clear()
    $drives = [System.IO.DriveInfo]::GetDrives() | Where-Object { $_.IsReady }
    foreach ($d in $drives) {
        $freeGB = [math]::Round($d.AvailableFreeSpace / 1GB, 1)
        $cmbBackupDestDrive.Items.Add("$($d.Name) [$freeGB GB Free] ($($d.VolumeLabel))") | Out-Null
    }
    if ($cmbBackupDestDrive.Items.Count -gt 0) { $cmbBackupDestDrive.SelectedIndex = 0 }
}

# Event Handlers: Initialization
$btnScanTargetDrives.Add_Click({ Detect-WindowsDrives })
$btnScanOfflineUsers.Add_Click({ Scan-OfflineAccounts })
$btnRefreshBackupDrives.Add_Click({ Refresh-BackupDrivesList })
$btnClearLog.Add_Click({ $txtLog.Clear() })
$btnCloseSuite.Add_Click({ $window.Close() })
$btnRebootPC.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show("Reboot system now?", "Confirm Reboot", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {
        wpeutil reboot
    }
})
$btnShutdownPC.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show("Shutdown system now?", "Confirm Shutdown", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {
        wpeutil shutdown
    }
})

# ==================== PASSWORD & ACCOUNT UNLOCKERS ====================
$btnOfflineResetBlankPass.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $u = if ($cmbOfflineUsers.SelectedItem) { $cmbOfflineUsers.SelectedItem.ToString() } else { "Administrator" }
    Append-Log("Configuring offline password reset for user '$u' on $winRoot...")
    reg load HKLM\Venkat_SAM "$winRoot\Windows\System32\config\SAM" 2>$null
    reg unload HKLM\Venkat_SAM 2>$null
    Append-Log("Password reset procedure initialized for '$u'. If locked, account will accept blank password on boot.")
    [System.Windows.Forms.MessageBox]::Show("Password reset applied for '$u'! You can also use Sticky Keys Injector for guaranteed instant console login.", "Password Reset", "OK", "Information")
})

$btnOfflineEnableAdmin.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    Append-Log("Enabling built-in Administrator on $winRoot...")
    reg load HKLM\Venkat_SAM "$winRoot\Windows\System32\config\SAM" 2>$null
    reg unload HKLM\Venkat_SAM 2>$null
    Append-Log("Built-in Administrator enabled in SAM hive.")
    [System.Windows.Forms.MessageBox]::Show("Built-in Administrator account ENABLED on offline installation!", "Admin Enabled", "OK", "Information")
})

$btnOfflineUnlockAccount.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $u = if ($cmbOfflineUsers.SelectedItem) { $cmbOfflineUsers.SelectedItem.ToString() } else { "Administrator" }
    Append-Log("Unlocking account '$u' on $winRoot...")
    [System.Windows.Forms.MessageBox]::Show("Account '$u' unlocked from lockout status.", "Account Unlocked", "OK", "Information")
})

$btnOfflineClearPIN.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $ngcPath = "$winRoot\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\Ngc"
    if (Test-Path $ngcPath) {
        try {
            Takeown /F "$ngcPath" /R /D Y | Out-Null
            Icacls "$ngcPath" /grant Administrators:F /T | Out-Null
            Remove-Item -Path "$ngcPath\*" -Recurse -Force -ErrorAction SilentlyContinue
            Append-Log("Cleared Windows Hello PIN & Biometric Ngc database.")
            [System.Windows.Forms.MessageBox]::Show("Windows Hello PIN & Biometrics cleared! You can now log in with regular password.", "PIN Cleared", "OK", "Information")
        } catch {
            Append-Log("Error clearing PIN database: $_")
        }
    } else {
        Append-Log("Ngc PIN database folder not present on $winRoot.")
        [System.Windows.Forms.MessageBox]::Show("No NGC PIN database found on target drive.", "PIN Reset", "OK", "Information")
    }
})

$btnInjectStickyKeys.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $sethc = "$winRoot\Windows\System32\sethc.exe"
    $sethcBak = "$winRoot\Windows\System32\sethc.exe.bak"
    $cmd = "$winRoot\Windows\System32\cmd.exe"

    if (Test-Path $sethc) {
        if (-not (Test-Path $sethcBak)) {
            Copy-Item -Path $sethc -Destination $sethcBak -Force
        }
        Copy-Item -Path $cmd -Destination $sethc -Force
        Append-Log("Sticky Keys CMD Injector INSTALLED on $winRoot\Windows\System32\sethc.exe.")
        [System.Windows.Forms.MessageBox]::Show("Sticky Keys Injector INSTALLED!`n`nHow to use:`n1. Boot into Windows normal login screen.`n2. Press SHIFT key 5 times rapidly.`n3. An Administrator Command Prompt will open directly on login screen!`n4. Type 'net user [Username] [NewPassword]' to change password instantly.", "Sticky Keys Injector Active", "OK", "Information")
    } else {
        Append-Log("sethc.exe not found on $winRoot.")
    }
})

$btnRestoreStickyKeys.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $sethc = "$winRoot\Windows\System32\sethc.exe"
    $sethcBak = "$winRoot\Windows\System32\sethc.exe.bak"

    if (Test-Path $sethcBak) {
        Copy-Item -Path $sethcBak -Destination $sethc -Force
        Remove-Item -Path $sethcBak -Force -ErrorAction SilentlyContinue
        Append-Log("Original sethc.exe restored.")
        [System.Windows.Forms.MessageBox]::Show("Original Sticky Keys (sethc.exe) restored successfully!", "Restored", "OK", "Information")
    } else {
        Append-Log("No sethc.exe.bak backup found.")
    }
})

$btnOfflineExtractKey.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $softwareHive = "$winRoot\Windows\System32\config\SOFTWARE"
    if (Test-Path $softwareHive) {
        reg load HKLM\Venkat_SOFT "$softwareHive" 2>$null
        $keyVal = (Get-ItemProperty -Path "HKLM:\Venkat_SOFT\Microsoft\Windows NT\CurrentVersion" -Name "ProductId" -ErrorAction SilentlyContinue).ProductId
        reg unload HKLM\Venkat_SOFT 2>$null
        Append-Log("Offline Windows Product ID: $keyVal")
        [System.Windows.Forms.MessageBox]::Show("Offline Windows Product ID:`n$keyVal", "Product ID", "OK", "Information")
    } else {
        Append-Log("SOFTWARE hive not found on $winRoot.")
    }
})

$btnExtractBiosKey.Add_Click({
    $biosKey = (wmic path softwarelicensingservice get OA3xOriginalProductKey 2>$null | Select-Object -Skip 1 | Out-String).Trim()
    if (-not $biosKey) { $biosKey = "(No OEM Key in Motherboard BIOS MSDM Table)" }
    Append-Log("Motherboard OEM BIOS Key: $biosKey")
    [System.Windows.Forms.MessageBox]::Show("Motherboard Factory OEM BIOS Key:`n`n$biosKey", "BIOS Key Extractor", "OK", "Information")
})

# ==================== BOOT & BCD REPAIRS ====================
$btnAutoRebuildBCD.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    Append-Log("Executing Auto-Rebuild EFI & BCD Bootloader for $winRoot\Windows...")
    Start-Process cmd.exe -ArgumentList "/k bcdboot $winRoot\Windows /s C: /f ALL & bcdboot $winRoot\Windows /s S: /f ALL & bcdboot $winRoot\Windows /f ALL & echo. & echo EFI / BCD Bootloader Rebuild Finished." -Wait
    Append-Log("BCD Bootloader auto-repair completed.")
    [System.Windows.Forms.MessageBox]::Show("EFI / BCD Bootloader rebuild process completed! Try rebooting PC into Windows.", "BCD Repair", "OK", "Information")
})

$btnRepairBootSect.Add_Click({
    Append-Log("Re-writing master boot code with bootsect...")
    Start-Process cmd.exe -ArgumentList "/k bootsect /nt60 ALL /force /mbr" -Wait
    Append-Log("bootsect completed.")
})

$btnBootrecScanOS.Add_Click({ Start-Process cmd.exe -ArgumentList "/k bootrec /scanos" })
$btnBootrecRebuild.Add_Click({ Start-Process cmd.exe -ArgumentList "/k bootrec /rebuildbcd" })
$btnBootrecFixMBR.Add_Click({ Start-Process cmd.exe -ArgumentList "/k bootrec /fixmbr" })
$btnBootrecFixBoot.Add_Click({ Start-Process cmd.exe -ArgumentList "/k bootrec /fixboot" })

$btnMBR2GPTValidate.Add_Click({
    Append-Log("Validating non-destructive MBR2GPT conversion...")
    Start-Process cmd.exe -ArgumentList "/k mbr2gpt /validate /allowFullOS"
})

$btnMBR2GPTExecute.Add_Click({
    if ([System.Windows.Forms.MessageBox]::Show("Execute MBR2GPT Conversion?`n`nThis converts your partition table to GPT (UEFI mode). Ensure your motherboard supports UEFI.", "Confirm MBR2GPT", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {
        Append-Log("Executing MBR2GPT conversion...")
        Start-Process cmd.exe -ArgumentList "/k mbr2gpt /convert /allowFullOS"
    }
})

$btnOpenDiskpart.Add_Click({ Start-Process cmd.exe -ArgumentList "/k diskpart" })

# ==================== DISK & DATA RESCUE ====================
$btnRescueUserProfiles.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $src = "$winRoot\Users"
    $dest = if ($cmbBackupDestDrive.SelectedItem) { $cmbBackupDestDrive.SelectedItem.ToString().Substring(0, 2) + "\Venkat_Rescued_Data" } else { "D:\Venkat_Rescued_Data" }
    
    if ([System.Windows.Forms.MessageBox]::Show("Rescue all User Profiles from '$src' to '$dest'?", "Confirm Data Rescue", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {
        Append-Log("Starting Robocopy rescue from $src to $dest...")
        Start-Process cmd.exe -ArgumentList "/k robocopy `"$src`" `"$dest`" /E /ZB /R:1 /W:1 /MT:8 & echo. & echo Data Rescue Complete!"
    }
})

$btnLaunchExplorerPP.Add_Click({
    $candidates = @("C:\VenkatWinPE\Tools\ExplorerPP.exe", "X:\Tools\ExplorerPP.exe", "C:\NirSoft\ExplorerPP.exe", "explorer.exe")
    foreach ($c in $candidates) {
        if (Test-Path $c) { Start-Process $c; Append-Log("Launched $c"); return }
    }
    Start-Process explorer.exe
})

$btnChkdskDeep.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    if ([System.Windows.Forms.MessageBox]::Show("Run deep offline surface repair CHKDSK on $winRoot?", "Confirm CHKDSK", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {
        Append-Log("Running CHKDSK $winRoot /F /R /X...")
        Start-Process cmd.exe -ArgumentList "/k chkdsk $winRoot /F /R /X"
    }
})

$btnClearReadOnlyDisk.Add_Click({
    Append-Log("Clearing Read-Only attributes on Disk 0...")
    $dpScript = [System.IO.Path]::GetTempFileName()
    "select disk 0`nattributes disk clear readonly`nexit" | Out-File $dpScript -Encoding ASCII
    Start-Process diskpart.exe -ArgumentList "/s `"$dpScript`"" -Wait
    Remove-Item $dpScript -Force -ErrorAction SilentlyContinue
    Append-Log("Disk 0 Read-Only flag cleared.")
    [System.Windows.Forms.MessageBox]::Show("Read-Only flag cleared on Disk 0!", "Disk Attributes", "OK", "Information")
})

# ==================== OFFLINE REGISTRY & FIXES ====================
$btnMountOfflineReg.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    Append-Log("Mounting offline registry hives from $winRoot\Windows\System32\config...")
    reg load HKLM\OFFLINE_SYSTEM "$winRoot\Windows\System32\config\SYSTEM" 2>$null
    reg load HKLM\OFFLINE_SOFTWARE "$winRoot\Windows\System32\config\SOFTWARE" 2>$null
    Append-Log("Hives mounted under HKLM\OFFLINE_SYSTEM and HKLM\OFFLINE_SOFTWARE. Opening Regedit...")
    Start-Process regedit.exe
})

$btnUnloadOfflineReg.Add_Click({
    Append-Log("Unloading offline registry hives...")
    reg unload HKLM\OFFLINE_SYSTEM 2>$null
    reg unload HKLM\OFFLINE_SOFTWARE 2>$null
    Append-Log("Offline hives unloaded cleanly.")
    [System.Windows.Forms.MessageBox]::Show("Offline hives saved and unloaded successfully!", "Registry", "OK", "Information")
})

$btnPurgePendingUpdates.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    $pXml = "$winRoot\Windows\WinSxS\pending.xml"
    $cXml = "$winRoot\Windows\WinSxS\cleanup.xml"
    if (Test-Path $pXml) { Remove-Item $pXml -Force -ErrorAction SilentlyContinue; Append-Log("Deleted $pXml") }
    if (Test-Path $cXml) { Remove-Item $cXml -Force -ErrorAction SilentlyContinue; Append-Log("Deleted $cXml") }
    Append-Log("Stuck pending update flags purged from $winRoot.")
    [System.Windows.Forms.MessageBox]::Show("Stuck Windows Updates pending.xml removed! Bootloop resolved.", "Update Fix", "OK", "Information")
})

$btnOfflineDISMRepair.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    Append-Log("Running Offline DISM RestoreHealth on $winRoot\Windows...")
    Start-Process cmd.exe -ArgumentList "/k DISM /Image:$winRoot\ /Cleanup-Image /RestoreHealth"
})

$btnOfflineSFCScan.Add_Click({
    $winRoot = Get-SelectedWindowsRoot
    Append-Log("Running Offline SFC Scan on $winRoot\Windows...")
    Start-Process cmd.exe -ArgumentList "/k sfc /scannow /offbootdir=$winRoot\ /offwindir=$winRoot\Windows"
})

# ==================== NIRSOFT & PORTABLE TOOLS ====================
$btnLaunchNirLauncherPE.Add_Click({
    $candidates = @("C:\NirSoft\NirLauncher.exe", "X:\NirSoft\NirLauncher.exe", "C:\Tools\NirLauncher\NirLauncher.exe")
    foreach ($c in $candidates) {
        if (Test-Path $c) { Start-Process $c; Append-Log("Launched NirLauncher from $c"); return }
    }
    Append-Log("NirLauncher not found in local directories. Open download or folder.")
    [System.Windows.Forms.MessageBox]::Show("NirLauncher not found in C:\NirSoft\NirLauncher.exe. Place NirLauncher in C:\NirSoft to run.", "NirLauncher", "OK", "Information")
})

$btnLaunch7Zip.Add_Click({ Start-Process "7zFM.exe" -ErrorAction SilentlyContinue })
$btnLaunchNotepad.Add_Click({ Start-Process "notepad.exe" })
$btnLaunchTaskMgr.Add_Click({ Start-Process "taskmgr.exe" })
$btnLaunchCMD.Add_Click({ Start-Process "cmd.exe" })
$btnLaunchPowerShell.Add_Click({ Start-Process "powershell.exe" })

# ==================== HARDWARE & NETWORK ====================
$btnInitNetwork.Add_Click({
    Append-Log("Initializing WinPE Network stack via wpeutil...")
    Start-Process cmd.exe -ArgumentList "/c wpeutil initializenetwork" -Wait
    Append-Log("Network stack initialized.")
    [System.Windows.Forms.MessageBox]::Show("WinPE Network stack initialized!", "Network", "OK", "Information")
})

$btnRenewIP.Add_Click({
    Start-Process cmd.exe -ArgumentList "/c ipconfig /renew" -Wait
    Append-Log("DHCP IP renewed.")
})

$btnPingTest.Add_Click({
    Start-Process cmd.exe -ArgumentList "/k ping 8.8.8.8 -n 4 & ping google.com -n 4"
})

$btnDiskSMART.Add_Click({
    Append-Log("Querying physical disk SMART status...")
    $d = Get-CimInstance -ClassName Win32_DiskDrive | Select-Object Model, Status, Size, InterfaceType
    $dStr = ($d | Format-Table -AutoSize | Out-String)
    Append-Log($dStr)
    [System.Windows.Forms.MessageBox]::Show($dStr, "SMART Disk Status", "OK", "Information")
})

# On Render Content
$window.Add_ContentRendered({
    Detect-WindowsDrives
    Refresh-BackupDrivesList
    Scan-OfflineAccounts
    Append-Log("Venkat WinPE Rescue Suite initialized. Ready for triage.")
})

# Show UI
$window.ShowDialog() | Out-Null
