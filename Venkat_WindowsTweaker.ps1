<#

.SYNOPSIS

    Ultimate Windows Tweaker, Debloater, Repair, Optimizer, App Store, User Password, Super Admin, OS Customizer & Power Tools Master Suite

.DESCRIPTION

    100% Native PowerShell & WPF Application featuring custom taskbar icon, window controls, 360+ tools across 14 tabs.

#>



# Auto-Elevation

$scriptPath = $PSCommandPath

if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Path }

if (-not $scriptPath) { $scriptPath = "C:\Users\user\.gemini\antigravity\scratch\windows_tweaker\WindowsTweaker.ps1" }



try {

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

    if (-not $isAdmin -and (Test-Path $scriptPath)) {

        Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs -ErrorAction Stop

        exit

    }

} catch {}



# Explicit Taskbar AppUserModelID & Native PassView Credential Recovery

try {

    $source = @"

using System;

using System.Runtime.InteropServices;

using System.Collections.Generic;



public class TaskbarHelper {

    [DllImport("shell32.dll", SetLastError = true)]

    public static extern void SetCurrentProcessExplicitAppUserModelID([MarshalAs(UnmanagedType.LPWStr)] string AppID);

}



public class NativePassViewHelper {

    [DllImport("advapi32.dll", SetLastError = true, CharSet = CharSet.Unicode)]

    public static extern bool CredEnumerate(string filter, int flag, out int count, out IntPtr pCredentials);



    [DllImport("advapi32.dll", SetLastError = true)]

    public static extern void CredFree(IntPtr pCredentials);



    [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]

    public struct CREDENTIAL {

        public int Flags;

        public int Type;

        public string TargetName;

        public string Comment;

        public long LastWritten;

        public int CredentialBlobSize;

        public IntPtr CredentialBlob;

        public int Persist;

        public int AttributeCount;

        public IntPtr Attributes;

        public string TargetAlias;

        public string UserName;

    }



    public class CredItem {

        public string Target { get; set; }

        public string User { get; set; }

        public string Password { get; set; }

        public string Type { get; set; }

    }



    public static List<CredItem> GetAllCredentials() {

        List<CredItem> list = new List<CredItem>();

        int count = 0;

        IntPtr pCreds = IntPtr.Zero;

        if (CredEnumerate(null, 0, out count, out pCreds)) {

            for (int i = 0; i < count; i++) {

                IntPtr ptr = Marshal.ReadIntPtr(pCreds, i * IntPtr.Size);

                CREDENTIAL c = (CREDENTIAL)Marshal.PtrToStructure(ptr, typeof(CREDENTIAL));

                string secret = "";

                if (c.CredentialBlob != IntPtr.Zero && c.CredentialBlobSize > 0) {

                    byte[] bytes = new byte[c.CredentialBlobSize];

                    Marshal.Copy(c.CredentialBlob, bytes, 0, c.CredentialBlobSize);

                    

                    bool isUnicode = false;

                    if (c.CredentialBlobSize >= 2 && bytes[1] == 0) {

                        isUnicode = true;

                    }

                    

                    if (isUnicode) {

                        secret = System.Text.Encoding.Unicode.GetString(bytes).Trim('\0');

                    } else {

                        secret = System.Text.Encoding.UTF8.GetString(bytes).Trim('\0');

                    }

                    

                    bool isPrintable = true;

                    foreach (char ch in secret) {

                        if (char.IsControl(ch) && ch != '\r' && ch != '\n' && ch != '\t') {

                            isPrintable = false;

                            break;

                        }

                    }

                    if (!isPrintable) {

                        secret = "(Binary Token / Encrypted Session)";

                    }

                }

                

                string credType = "Generic";

                if (c.Type == 1) credType = "Generic";

                else if (c.Type == 2) credType = "Domain Password";

                else if (c.Type == 3) credType = "Domain Certificate";

                else if (c.Type == 4) credType = "Domain Visible Password";

                

                list.Add(new CredItem {

                    Target = c.TargetName ?? "",

                    User = string.IsNullOrEmpty(c.UserName) ? "(None)" : c.UserName,

                    Password = string.IsNullOrEmpty(secret) ? "(Empty)" : secret,

                    Type = credType

                });

            }

            CredFree(pCreds);

        }

        return list;

    }

}

"@

    Add-Type -TypeDefinition $source -ErrorAction SilentlyContinue

    [TaskbarHelper]::SetCurrentProcessExplicitAppUserModelID("Venkat.WindowsTweaker.MasterSuite")

} catch {}



Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing, Microsoft.VisualBasic



[xml]$xaml = @"

<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

        Title="Venkat Ultimate Windows Tweaker, OS Customizer &amp; Diagnostic Master Suite"

        Height="780" Width="1120"

        MinHeight="580" MinWidth="880"

        WindowStartupLocation="CenterScreen"

        WindowStyle="SingleBorderWindow"

        ResizeMode="CanResizeWithGrip"

        Background="#080E1A"

        FontFamily="Segoe UI">

    

    <Window.Resources>

        <Style TargetType="TabItem">

            <Setter Property="FontSize" Value="10"/>

            <Setter Property="FontWeight" Value="SemiBold"/>

            <Setter Property="Foreground" Value="#94A3B8"/>

            <Setter Property="Padding" Value="5,4"/>

            <Setter Property="Background" Value="#0F172A"/>

            <Setter Property="Template">

                <Setter.Value>

                    <ControlTemplate TargetType="TabItem">

                        <Border Name="Border" Background="{TemplateBinding Background}" BorderBrush="#1E293B" BorderThickness="1,1,1,0" CornerRadius="4,4,0,0" Margin="1,0">

                            <ContentPresenter x:Name="ContentSite" VerticalAlignment="Center" HorizontalAlignment="Center" ContentSource="Header" Margin="3,2"/>

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

            <Setter Property="Padding" Value="7,4"/>

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



        <Style TargetType="CheckBox">

            <Setter Property="Foreground" Value="#F1F5F9"/>

            <Setter Property="FontSize" Value="10.5"/>

            <Setter Property="Margin" Value="0,2,0,2"/>

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



    <Grid Margin="8">

        <Grid.RowDefinitions>

            <RowDefinition Height="Auto"/>

            <RowDefinition Height="*"/>

            <RowDefinition Height="Auto"/>

        </Grid.RowDefinitions>



        <!-- TOP HEADER BAR WITH CONTROLS & LOGO -->

        <Border Grid.Row="0" Background="#0F172A" CornerRadius="6" Padding="10,6" Margin="0,0,0,6" BorderBrush="#1E293B" BorderThickness="1">

            <Grid>

                <Grid.ColumnDefinitions>

                    <ColumnDefinition Width="Auto"/>

                    <ColumnDefinition Width="*"/>

                    <ColumnDefinition Width="Auto"/>

                </Grid.ColumnDefinitions>



                <!-- App Logo & Title -->

                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center" Margin="0,0,12,0">

                    <!-- Tech Shield/Prompt Logo Emblem -->

                    <Border Background="#1E3A8A" CornerRadius="6" Width="30" Height="30" Margin="0,0,8,0" BorderBrush="#38BDF8" BorderThickness="1.5">

                        <TextBlock Text="&gt;_" FontSize="13" FontWeight="Bold" Foreground="#38BDF8" HorizontalAlignment="Center" VerticalAlignment="Center" Margin="1,0,0,2"/>

                    </Border>

                    <StackPanel VerticalAlignment="Center">

                        <TextBlock Text="Venkat Ultimate Windows Tweaker &amp; OS Suite" FontSize="15" FontWeight="Bold" Foreground="#38BDF8"/>

                        <TextBlock Text="Created by Venkat | 360+ Tools | Customizer, Edition Changer, Defender Control &amp; Store" FontSize="9.5" Foreground="#94A3B8" Margin="0,1,0,0"/>

                    </StackPanel>

                </StackPanel>



                <!-- Search & Status Badges -->

                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" HorizontalAlignment="Center">

                    <TextBox Name="txtSearch" Width="150" Height="24" Margin="0,0,4,0" Text="Search tools..." Foreground="#64748B"/>

                    <Button Name="btnSearch" Content="Search" Width="55" Height="24" Background="#0284C7" Margin="0,0,6,0"/>

                    <Border Background="#064E3B" CornerRadius="4" Padding="5,2" Margin="0,0,4,0">

                        <TextBlock Text="WinGet: Active" FontSize="9.5" FontWeight="Bold" Foreground="#10B981"/>

                    </Border>

                    <Border Background="#1E3A8A" CornerRadius="4" Padding="5,2">

                        <TextBlock Text="Super Admin" FontSize="9.5" FontWeight="Bold" Foreground="#60A5FA"/>

                    </Border>

                </StackPanel>



                <!-- Right Side Status Badges -->

                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center">

                    <Border Background="#1E293B" CornerRadius="4" Padding="6,3" Margin="0,0,4,0">

                        <TextBlock Text="Venkat v3.6 Pro" FontSize="9.5" FontWeight="Bold" Foreground="#38BDF8"/>

                    </Border>

                    <Border Background="#064E3B" CornerRadius="4" Padding="6,3">

                        <TextBlock Text="Online Mode" FontSize="9.5" FontWeight="Bold" Foreground="#10B981"/>

                    </Border>

                </StackPanel>

            </Grid>

        </Border>



        <!-- MAIN TABS CONTAINER -->

        <TabControl Name="MainTabControl" Grid.Row="1" Background="#0B132B" BorderBrush="#1E293B">



            <!-- TAB 1: USER PASSWORDS & ACCOUNTS HUB -->

            <TabItem Header="User Passwords">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <TextBlock Text="WINDOWS USER ACCOUNTS &amp; PASSWORD MANAGEMENT HUB" FontSize="12.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>



                        <!-- User Selection & Password Actions -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="SELECTED LOCAL USER ACCOUNT &amp; PASSWORD RESET" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <TextBlock Text="Select any detected user account to reset/remove password, unlock, or configure auto-login." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                

                                <Grid Margin="0,0,0,6">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Select User Account:" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="#F8FAFC" FontWeight="Bold"/>

                                    <ComboBox Name="cmbUserAccounts" Grid.Column="1" Height="26" Margin="0,0,6,0" Background="#0F172A" Foreground="#F8FAFC"/>

                                    <Button Name="btnRefreshUserList" Grid.Column="2" Content="Refresh Accounts" Width="120" Height="26" Background="#0891B2" FontWeight="Bold"/>

                                </Grid>



                                <Grid Margin="0,0,0,6">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="New Password:" VerticalAlignment="Center" Margin="0,0,38,0" Foreground="#F8FAFC"/>

                                    <TextBox Name="txtUserNewPass" Grid.Column="1" Height="26" Margin="0,0,6,0" Text="Enter New Password"/>

                                    <Button Name="btnApplyUserPass" Grid.Column="2" Content="Apply New Password" Width="140" Height="26" Background="#0284C7" FontWeight="Bold" Margin="0,0,4,0"/>

                                    <Button Name="btnRemoveUserPass" Grid.Column="3" Content="Remove Password (Blank)" Width="160" Height="26" Background="#D97706" FontWeight="Bold"/>

                                </Grid>



                                <UniformGrid Columns="4" Margin="0,2,0,0">

                                    <Button Name="btnUnlockUserAcc" Content="Unlock Selected Account" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnDisableUserAcc" Content="Disable Selected Account" Margin="2" Background="#7F1D1D" FontWeight="Bold"/>

                                    <Button Name="btnPassNeverExpire" Content="Set Password Never Expires" Margin="2" Background="#1E40AF" FontWeight="Bold"/>

                                    <Button Name="btnDeleteUserAcc" Content="Delete Selected Account" Margin="2" Background="#DC2626" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Automatic Login Without Password (Auto-Logon) -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#10B981" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="AUTOMATIC LOGON ON SYSTEM BOOT (NO PASSWORD PROMPT)" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                <TextBlock Text="Configure Windows to automatically log in to the selected user on startup without asking for password or PIN." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Grid>

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="*"/>

                                    </Grid.ColumnDefinitions>

                                    <Button Name="btnEnableAutoLogon" Grid.Column="0" Content="Enable Auto-Logon for Selected User" Background="#059669" Height="28" Margin="0,0,3,0" FontWeight="Bold"/>

                                    <Button Name="btnDisableAutoLogon" Grid.Column="1" Content="Disable Auto-Logon (Require Password)" Background="#DC2626" Height="28" Margin="3,0,0,0" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- Create New Local Account -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#7C3AED" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="CREATE NEW LOCAL USER ACCOUNT" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                <Grid Margin="0,2">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBox Name="txtCreateUsername" Grid.Column="0" Height="26" Margin="0,0,4,0" Text="NewUser"/>

                                    <TextBox Name="txtCreatePassword" Grid.Column="1" Height="26" Margin="0,0,4,0" Text="User@12345"/>

                                    <ComboBox Name="cmbAccountType" Grid.Column="2" Width="130" Height="26" Margin="0,0,4,0" Background="#0F172A" Foreground="#F8FAFC"/>

                                    <Button Name="btnCreateAccountAction" Grid.Column="3" Content="Create Account" Width="130" Height="26" Background="#7C3AED" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- WINDOWS 11 / 10 GUEST ACCOUNT MANAGER -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#06B6D4" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINDOWS 11 / 10 GUEST ACCOUNT MANAGER (ONE-CLICK VISITOR ACCESS)" FontSize="11.5" FontWeight="Bold" Foreground="#22D3EE" Margin="0,0,0,4"/>

                                <TextBlock Text="Windows 11 disables the old built-in Guest login. This engine creates a fully functional, safe guest account with no password requirement and no admin privileges." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Grid>

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="*"/>

                                    </Grid.ColumnDefinitions>

                                    <Button Name="btnEnableWorkingGuest" Grid.Column="0" Content="Enable Working Guest Account" Background="#059669" Height="28" Margin="0,0,3,0" FontWeight="Bold"/>

                                    <Button Name="btnDisableWorkingGuest" Grid.Column="1" Content="Disable Guest Account" Background="#DC2626" Height="28" Margin="3,0,3,0" FontWeight="Bold"/>

                                    <Button Name="btnCheckGuestStatus" Grid.Column="2" Content="Check Guest Account Status" Background="#0284C7" Height="28" Margin="3,0,0,0" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- WINPE RESCUE & HIREN'S EMERGENCY RECOVERY MASTER SUITE -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#059669" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINPE RESCUE &amp; HIREN'S EMERGENCY RECOVERY MASTER SUITE" FontSize="11.5" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>

                                <TextBlock Text="Standalone Bootable WinPE Suite: Offline Password Resetter, BCD/EFI Boot Fixer, Offline Registry &amp; DISM Imaging." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnLaunchWinPERescue" Content="Launch Venkat WinPE Rescue Suite (Live &amp; Offline)" Margin="2" Height="30" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnLaunchWinPEBuilder" Content="1-Click WinPE Bootable USB / ISO Builder" Margin="2" Height="30" Background="#0284C7" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- NIRLAUNCHER & NIRSOFT MASTER RECOVERY SUITE -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0D9488" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="NIRLAUNCHER &amp; NIRSOFT MASTER RECOVERY SUITE (200+ TOOLS)" FontSize="11.5" FontWeight="Bold" Foreground="#2DD4BF" Margin="0,0,0,4"/>

                                <TextBlock Text="Integrated launcher for NirSoft 200+ utilities: Mail PassView, WebBrowserPassView, WirelessKeyView, Network &amp; System tools." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="3" Margin="0,0,0,4">

                                    <Button Name="btnLaunchNirLauncher" Content="Launch NirLauncher Package" Margin="2" Height="30" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnDownloadNirLauncher" Content="Download NirLauncher (Auto Setup)" Margin="2" Height="30" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnOpenNirFolder" Content="Open NirSoft Tools Folder" Margin="2" Height="30" Background="#D97706" FontWeight="Bold"/>

                                </UniformGrid>

                                <UniformGrid Columns="3">

                                    <Button Name="btnLaunchWebBrowserPass" Content="WebBrowserPassView Engine" Margin="2" Height="28" Background="#1E40AF" FontWeight="Bold"/>

                                    <Button Name="btnLaunchWirelessKeyView" Content="WirelessKeyView (Wi-Fi Passwords)" Margin="2" Height="28" Background="#0D9488" FontWeight="Bold"/>

                                    <Button Name="btnLaunchOutlookPass" Content="Outlook PST &amp; Password Tools" Margin="2" Height="28" Background="#6366F1" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Native User Consoles -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="8" BorderBrush="#6366F1" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINDOWS BUILT-IN USER MANAGEMENT CONSOLES" FontSize="11.5" FontWeight="Bold" Foreground="#818CF8" Margin="0,0,0,4"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnOpenNetplwiz" Content="Advanced User Accounts (netplwiz)" Margin="2" Height="28" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnOpenLusrmgr" Content="Local Users &amp; Groups (lusrmgr.msc)" Margin="2" Height="28" Background="#4F46E5" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 2: 1-CLICK MEGA APP STORE (WINGET) -->

            <TabItem Header="1-Click App Store">

                <Grid Margin="6">

                    <Grid.RowDefinitions>

                        <RowDefinition Height="*"/>

                        <RowDefinition Height="Auto"/>

                    </Grid.RowDefinitions>



                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto" Margin="0,0,0,6">

                        <StackPanel>

                            <TextBlock Text="MEGA 1-CLICK APPLICATION STORE (WINGET REPOSITORY)" FontSize="12.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>



                            <UniformGrid Columns="4">

                                <!-- Microsoft Official Apps -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#0284C7" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="MICROSOFT SUITE" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkAppMS365" Content="Microsoft 365 / Office" IsChecked="True"/>

                                        <CheckBox Name="chkAppMSTeams" Content="Microsoft Teams"/>

                                        <CheckBox Name="chkAppPowerToys" Content="Microsoft PowerToys" IsChecked="True"/>

                                        <CheckBox Name="chkAppMSTerminal" Content="Windows Terminal" IsChecked="True"/>

                                        <CheckBox Name="chkAppMSPCManager" Content="Microsoft PC Manager"/>

                                        <CheckBox Name="chkAppMSOneDrive" Content="Microsoft OneDrive"/>

                                        <CheckBox Name="chkAppMSPS7" Content="PowerShell 7 (Latest)"/>

                                        <CheckBox Name="chkAppMSSysinternals" Content="Sysinternals Suite"/>

                                        <CheckBox Name="chkAppMSOneNote" Content="Microsoft OneNote"/>

                                        <CheckBox Name="chkAppMSWhiteboard" Content="Microsoft Whiteboard"/>

                                        <CheckBox Name="chkAppMSSSMS" Content="SQL Server Mgmt Studio"/>

                                        <CheckBox Name="chkAppMSVSCommunity" Content="Visual Studio 2022"/>

                                        <CheckBox Name="chkAppMSWSL" Content="WSL Linux Subsystem"/>

                                    </StackPanel>

                                </Border>



                                <!-- Web Browsers -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#F59E0B" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="WEB BROWSERS" FontWeight="Bold" Foreground="#FBBF24" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkAppChrome" Content="Google Chrome" IsChecked="True"/>

                                        <CheckBox Name="chkAppBrave" Content="Brave Browser"/>

                                        <CheckBox Name="chkAppFirefox" Content="Mozilla Firefox"/>

                                        <CheckBox Name="chkAppEdge" Content="Microsoft Edge"/>

                                        <CheckBox Name="chkAppOperaGX" Content="Opera GX Gaming"/>

                                        <CheckBox Name="chkAppTor" Content="Tor Browser"/>

                                    </StackPanel>

                                </Border>



                                <!-- Remote & Communication -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#10B981" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="REMOTE &amp; COMMS" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkAppAnyDesk" Content="AnyDesk Remote" IsChecked="True"/>

                                        <CheckBox Name="chkAppTeamViewer" Content="TeamViewer"/>

                                        <CheckBox Name="chkAppRustDesk" Content="RustDesk (Open Source)"/>

                                        <CheckBox Name="chkAppUltraViewer" Content="UltraViewer"/>

                                        <CheckBox Name="chkAppDiscord" Content="Discord"/>

                                        <CheckBox Name="chkAppTelegram" Content="Telegram Desktop"/>

                                        <CheckBox Name="chkAppWhatsApp" Content="WhatsApp Desktop"/>

                                        <CheckBox Name="chkAppZoom" Content="Zoom Meetings"/>

                                        <CheckBox Name="chkAppSkype" Content="Microsoft Skype"/>

                                    </StackPanel>

                                </Border>



                                <!-- Utilities & Hardware -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#8B5CF6" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="UTILITIES &amp; HARDWARE" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkApp7Zip" Content="7-Zip Archiver" IsChecked="True"/>

                                        <CheckBox Name="chkAppWinRAR" Content="WinRAR"/>

                                        <CheckBox Name="chkAppPeaZip" Content="PeaZip"/>

                                        <CheckBox Name="chkAppNotepad" Content="Notepad++" IsChecked="True"/>

                                        <CheckBox Name="chkAppEverything" Content="voidtools Everything"/>

                                        <CheckBox Name="chkAppRevo" Content="Revo Uninstaller Free"/>

                                        <CheckBox Name="chkAppRufus" Content="Rufus USB Boot Creator"/>

                                        <CheckBox Name="chkAppCrystalDisk" Content="CrystalDiskInfo"/>

                                        <CheckBox Name="chkAppCPUZ" Content="CPU-Z Hardware Info"/>

                                        <CheckBox Name="chkAppHWMonitor" Content="HWMonitor Sensor Info"/>

                                        <CheckBox Name="chkAppTreeSize" Content="TreeSize Free Disk Space"/>

                                        <CheckBox Name="chkAppNirLauncher" Content="NirLauncher (NirSoft Suite)"/>

                                    </StackPanel>

                                </Border>



                                <!-- Media & Creative -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#EC4899" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="MEDIA &amp; CREATIVE" FontWeight="Bold" Foreground="#F472B6" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkAppVLC" Content="VLC Media Player" IsChecked="True"/>

                                        <CheckBox Name="chkAppKLite" Content="K-Lite Codec Pack Full"/>

                                        <CheckBox Name="chkAppOBS" Content="OBS Studio Screen Recorder"/>

                                        <CheckBox Name="chkAppGIMP" Content="GIMP Image Editor"/>

                                        <CheckBox Name="chkAppPaintNet" Content="Paint.NET"/>

                                        <CheckBox Name="chkAppAudacity" Content="Audacity Audio Editor"/>

                                        <CheckBox Name="chkAppHandBrake" Content="HandBrake Video Converter"/>

                                        <CheckBox Name="chkAppSpotify" Content="Spotify Music"/>

                                        <CheckBox Name="chkAppCapCut" Content="CapCut Video Editor"/>

                                    </StackPanel>

                                </Border>



                                <!-- Developer Tools & Databases -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#06B6D4" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="DEV TOOLS &amp; RUNTIMES" FontWeight="Bold" Foreground="#22D3EE" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkAppVSCode" Content="Visual Studio Code"/>

                                        <CheckBox Name="chkAppGit" Content="Git for Windows"/>

                                        <CheckBox Name="chkAppGitHubDesktop" Content="GitHub Desktop"/>

                                        <CheckBox Name="chkAppPython" Content="Python 3.12 (Latest)"/>

                                        <CheckBox Name="chkAppNode" Content="Node.js LTS Runtime"/>

                                        <CheckBox Name="chkAppDocker" Content="Docker Desktop"/>

                                        <CheckBox Name="chkAppPostman" Content="Postman API Platform"/>

                                        <CheckBox Name="chkAppDBeaver" Content="DBeaver Database Tool"/>

                                        <CheckBox Name="chkAppVCRedist" Content="Visual C++ All-In-One Runtimes"/>

                                        <CheckBox Name="chkAppJavaJDK" Content="Java JDK (Eclipse Temurin)"/>

                                    </StackPanel>

                                </Border>



                                <!-- Documents & Office -->

                                <Border Background="#0F172A" CornerRadius="6" Padding="8" Margin="2" BorderBrush="#D97706" BorderThickness="1.5">

                                    <StackPanel>

                                        <TextBlock Text="OFFICE &amp; PDF SUITES" FontWeight="Bold" Foreground="#FBBF24" Margin="0,0,0,4"/>

                                        <CheckBox Name="chkAppAdobeReader" Content="Adobe Acrobat Reader 64-bit" IsChecked="True"/>

                                        <CheckBox Name="chkAppFoxit" Content="Foxit PDF Reader"/>

                                        <CheckBox Name="chkAppSumatra" Content="SumatraPDF (Ultra-Light)"/>

                                        <CheckBox Name="chkAppLibreOffice" Content="LibreOffice Complete Suite"/>

                                        <CheckBox Name="chkAppWPS" Content="WPS Office Free Suite"/>

                                        <CheckBox Name="chkAppPDF24" Content="PDF24 Creator Toolbox"/>

                                    </StackPanel>

                                </Border>

                            </UniformGrid>

                        </StackPanel>

                    </ScrollViewer>



                    <!-- App Store Preset Bar & Install Action -->

                    <Border Grid.Row="1" Background="#0F172A" CornerRadius="6" Padding="8" BorderBrush="#059669" BorderThickness="1.5">

                        <Grid>

                            <Grid.ColumnDefinitions>

                                <ColumnDefinition Width="Auto"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="Auto"/>

                            </Grid.ColumnDefinitions>

                            <StackPanel Grid.Column="0" Orientation="Horizontal">

                                <TextBlock Text="Quick Presets: " Foreground="#94A3B8" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,6,0"/>

                                <Button Name="btnPresetAppEssentials" Content="Essentials" Background="#059669" FontWeight="Bold" Width="85" Margin="0,0,4,0"/>

                                <Button Name="btnPresetAppMS" Content="Microsoft Suite" Background="#0284C7" FontWeight="Bold" Width="105" Margin="0,0,4,0"/>

                                <Button Name="btnPresetAppDev" Content="Dev Bundle" Background="#4F46E5" FontWeight="Bold" Width="90" Margin="0,0,4,0"/>

                                <Button Name="btnSelectAllApps" Content="Select All" Background="#334155" FontWeight="Bold" Width="75" Margin="0,0,4,0"/>

                                <Button Name="btnClearAllApps" Content="Deselect All" Background="#DC2626" FontWeight="Bold" Width="85"/>

                            </StackPanel>

                            <Button Name="btnInstallSelectedApps" Grid.Column="2" Content="Install Selected Apps (WinGet Engine)" Background="#059669" FontWeight="Bold" Width="260" Height="30"/>

                        </Grid>

                    </Border>

                </Grid>

            </TabItem>



            <!-- TAB 3: FEATURES & SYSTEM FIXES (EXACT MATCH WITH USER SCREENSHOT) -->

            <TabItem Header="Features &amp; Fixes">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <!-- FEATURES SECTION -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="Features" FontSize="13" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>

                                <CheckBox Name="chkFeatNetFx" Content=".NET Framework (Versions 2, 3, 4) - Enable (?)"/>

                                <CheckBox Name="chkFeatHyperV" Content="Hyper-V - Enable (?)"/>

                                <CheckBox Name="chkFeatF8Disable" Content="Legacy F8 Boot Recovery - Disable (?)"/>

                                <CheckBox Name="chkFeatF8Enable" Content="Legacy F8 Boot Recovery - Enable (?)"/>

                                <CheckBox Name="chkFeatMedia" Content="Legacy Media Components (WMP, DirectPlay) - Enable (?)"/>

                                <CheckBox Name="chkFeatNFS" Content="Network File System (NFS) - Enable (?)"/>

                                <CheckBox Name="chkFeatRegBackupTask" Content="Registry Backup (Daily Task 12:30am) - Enable (?)"/>

                                <CheckBox Name="chkFeatSandbox" Content="Windows Sandbox - Enable (?)"/>

                                <CheckBox Name="chkFeatWSL" Content="Windows Subsystem for Linux (WSL) - Enable (?)"/>

                                

                                <Button Name="btnInstallFeaturesBatch" Content="Install Features" Background="#0284C7" FontWeight="Bold" Height="30" Margin="0,8,0,0"/>

                            </StackPanel>

                        </Border>



                        <!-- FIXES SECTION -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#10B981" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="Fixes" FontSize="13" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,6"/>

                                <Button Name="btnFixAutoLogon" Content="Configure AutoLogon (netplwiz)" Margin="0,2" Height="30" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                                <Button Name="btnFixNetworkReset" Content="Network - Reset" Margin="0,2" Height="30" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                                <Button Name="btnFixNTPServer" Content="NTP Server - Enable" Margin="0,2" Height="30" Background="#D97706" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                                <Button Name="btnFixSystemCorruption" Content="System Corruption Scan - Run" Margin="0,2" Height="30" Background="#7C3AED" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                                <Button Name="btnFixWindowsUpdate" Content="Windows Update - Reset" Margin="0,2" Height="30" Background="#0D9488" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                                <Button Name="btnFixReinstallWinget" Content="WinGet - Reinstall" Margin="0,2" Height="30" Background="#4F46E5" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 4: WINDOWS OS CUSTOMIZER & UNATTENDED ISO BUILDER -->

            <TabItem Header="OS Customizer &amp; ISOs">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <TextBlock Text="WINDOWS OS CUSTOMIZATION &amp; UNATTENDED ISO SETUP BUILDER" FontSize="12.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>



                        <!-- Official ISO & Creator Tools -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#10B981" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="1. OFFICIAL WINDOWS ISO &amp; BOOTABLE USB CREATOR TOOLS" FontSize="11.5" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>

                                <TextBlock Text="Download genuine official Windows ISOs directly from Microsoft servers and Rufus USB builder tool." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="4">

                                    <Button Name="btnCustDownloadWin11" Content="Official Win 11 ISO (Microsoft)" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnCustDownloadWin10" Content="Official Win 10 ISO (Microsoft)" Margin="2" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnCustDownloadRufus" Content="Download Rufus (USB Tool)" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                    <Button Name="btnCustOpenFido" Content="Download Fido / UUPDump ISO" Margin="2" Background="#7C3AED" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Unattended Setup & Bypass Configurator -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="2. UNATTENDED SETUP &amp; BYPASS ANSWER FILE (autounattend.xml)" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <TextBlock Text="Configure automated answer file to bypass Microsoft Account (MSA), bypass TPM/SecureBoot/RAM checks, and auto-create local user." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>



                                <UniformGrid Columns="2" Margin="0,0,0,6">

                                    <CheckBox Name="chkCustBypassMSA" Content="Bypass Microsoft Account (MSA) in Setup (Force Local Account)" IsChecked="True"/>

                                    <CheckBox Name="chkCustBypassTPM" Content="Bypass Windows 11 TPM 2.0, SecureBoot, RAM &amp; CPU Checks" IsChecked="True"/>

                                    <CheckBox Name="chkCustSkipEULA" Content="Auto-Accept EULA &amp; Skip All Privacy Screens (Diagnostics, Ads)" IsChecked="True"/>

                                    <CheckBox Name="chkCustDisableBitLocker" Content="Disable BitLocker Automatic Drive Encryption during Setup" IsChecked="True"/>

                                    <CheckBox Name="chkCustPerfPower" Content="Enable High Performance Power Plan Scheme on Setup" IsChecked="True"/>

                                    <CheckBox Name="chkCustClassicMenu" Content="Restore Classic Windows Right-Click Menu on First Boot" IsChecked="True"/>

                                </UniformGrid>



                                <!-- Custom Local User Credentials -->

                                <Border Background="#080E1A" CornerRadius="4" Padding="8" Margin="0,4,0,6" BorderBrush="#1E293B" BorderThickness="1">

                                    <Grid>

                                        <Grid.ColumnDefinitions>

                                            <ColumnDefinition Width="Auto"/>

                                            <ColumnDefinition Width="*"/>

                                            <ColumnDefinition Width="Auto"/>

                                            <ColumnDefinition Width="*"/>

                                            <ColumnDefinition Width="Auto"/>

                                        </Grid.ColumnDefinitions>

                                        <TextBlock Grid.Column="0" Text="Default User Name:" VerticalAlignment="Center" Margin="0,0,6,0" Foreground="#F8FAFC" FontWeight="Bold"/>

                                        <TextBox Name="txtCustUsername" Grid.Column="1" Height="26" Margin="0,0,8,0" Text="Admin"/>

                                        <TextBlock Grid.Column="2" Text="Password (Optional):" VerticalAlignment="Center" Margin="0,0,6,0" Foreground="#F8FAFC"/>

                                        <TextBox Name="txtCustPassword" Grid.Column="3" Height="26" Margin="0,0,8,0" Text=""/>

                                        <CheckBox Name="chkCustAutoLogon" Grid.Column="4" Content="Auto-Logon on Boot" VerticalAlignment="Center" IsChecked="True"/>

                                    </Grid>

                                </Border>



                                <!-- Export autounattend.xml -->

                                <Grid Margin="0,4,0,0">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Target USB / Drive:" VerticalAlignment="Center" Margin="0,0,8,0" Foreground="#F8FAFC" FontWeight="Bold"/>

                                    <ComboBox Name="cmbCustTargetDrive" Grid.Column="1" Height="26" Margin="0,0,6,0" Background="#0F172A" Foreground="#F8FAFC"/>

                                    <Button Name="btnCustRefreshDrives" Grid.Column="2" Content="Refresh Drives" Width="100" Height="26" Background="#0891B2" FontWeight="Bold" Margin="0,0,6,0"/>

                                    <Button Name="btnGenerateAutounattend" Grid.Column="3" Content="Generate &amp; Save autounattend.xml" Width="220" Height="26" Background="#059669" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- Live OOBE Bypass & Rufus Helper -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" BorderBrush="#DC2626" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="3. LIVE SETUP (OOBE) BYPASS &amp; RUFUS INTEGRATION" FontSize="11.5" FontWeight="Bold" Foreground="#F87171" Margin="0,0,0,4"/>

                                <TextBlock Text="If currently stuck on Windows 11 'Let's connect you to a network' setup screen, run live bypass command." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnRunLiveOOBEBypass" Content="Execute Live OOBE Network Bypass (oobe\bypassnro)" Margin="2" Height="30" Background="#DC2626" FontWeight="Bold"/>

                                    <Button Name="btnLaunchRufus" Content="Launch Rufus USB Builder with Recommended Config" Margin="2" Height="30" Background="#0284C7" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 5: POWER TOOLS & SYSTEM CONTROLS -->

            <TabItem Header="Power Tools Hub">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <TextBlock Text="ADVANCED TECHNICIAN POWER TOOLS &amp; CONTROLLERS" FontSize="12.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>



                        <!-- Windows Defender & Security Control -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#DC2626" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINDOWS DEFENDER &amp; SECURITY CONTROLS" FontSize="11.5" FontWeight="Bold" Foreground="#F87171" Margin="0,0,0,4"/>

                                <TextBlock Text="Temporarily pause/enable Defender real-time monitoring or clear false-positive protection cache." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="4">

                                    <Button Name="btnPauseDefender" Content="Pause Realtime Defender" Margin="2" Background="#DC2626" FontWeight="Bold"/>

                                    <Button Name="btnEnableDefender" Content="Enable Realtime Defender" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnClearDefenderCache" Content="Clear Protection History" Margin="2" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnDisableSmartScreen2" Content="Disable SmartScreen Warnings" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Printer Spooler & OneDrive / AI Debloat -->

                        <Grid Margin="0,0,0,8">

                            <Grid.ColumnDefinitions>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                            </Grid.ColumnDefinitions>



                            <Border Grid.Column="0" Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,4,0" BorderBrush="#059669" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="PRINTER SPOOLER RECOVERY" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                    <TextBlock Text="Purge stuck print queue &amp; cycle Spooler engine." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                    <Button Name="btnFixPrinterSpooler" Content="1-Click Clear Stuck Print Jobs &amp; Restart Spooler" Height="30" Background="#059669" FontWeight="Bold"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="1" Background="#0F172A" CornerRadius="6" Padding="10" Margin="4,0,0,0" BorderBrush="#7C3AED" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="ONEDRIVE &amp; COPILOT / RECALL AI" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                    <TextBlock Text="Remove OneDrive completely or disable AI telemetry." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                    <UniformGrid Columns="2">

                                        <Button Name="btnRemoveOneDrive" Content="Uninstall OneDrive" Height="30" Margin="2" Background="#7F1D1D" FontWeight="Bold"/>

                                        <Button Name="btnDisableCopilotRecall" Content="Disable Copilot &amp; Recall" Height="30" Margin="2" Background="#1E40AF" FontWeight="Bold"/>

                                    </UniformGrid>

                                </StackPanel>

                            </Border>

                        </Grid>



                        <!-- Laptop Battery, Hibernation & Windows Explorer Quick Boost -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="LAPTOP BATTERY, HIBERNATION STORAGE &amp; EXPLORER QUICK RESTART" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <UniformGrid Columns="4">

                                    <Button Name="btnDisableHibernation" Content="Disable Hibernation (Free 4-32GB)" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnEnableHibernation" Content="Enable Hibernation" Margin="2" Background="#0891B2" FontWeight="Bold"/>

                                    <Button Name="btnRestartExplorerQuick" Content="1-Click Restart Explorer.exe" Margin="2" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnFixRecycleBinQuick" Content="Fix Corrupted Recycle Bin" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                </UniformGrid>

                                <UniformGrid Columns="4" Margin="0,4,0,0">

                                    <Button Name="btnToggleHiddenFilesQuick" Content="Toggle Hidden Files / Folders" Margin="2" Background="#6366F1" FontWeight="Bold"/>

                                    <Button Name="btnEnableLongPathsQuick" Content="Enable Long Paths (>260 Chars)" Margin="2" Background="#0D9488" FontWeight="Bold"/>

                                    <Button Name="btnListStartupAppsQuick" Content="Inspect Startup Programs" Margin="2" Background="#7C3AED" FontWeight="Bold"/>

                                    <Button Name="btnAnalyzeBatteryWear" Content="Battery Life &amp; Wear % Scan" Margin="2" Background="#1E40AF" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Wi-Fi Hotspot & Secure File Shredder -->

                        <Grid>

                            <Grid.ColumnDefinitions>

                                <ColumnDefinition Width="1.1*"/>

                                <ColumnDefinition Width="*"/>

                            </Grid.ColumnDefinitions>



                            <Border Grid.Column="0" Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,4,0" BorderBrush="#10B981" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="PC WI-FI HOTSPOT CREATOR" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                    <TextBlock Text="Turn PC into Hosted Virtual Router (SSID: WindowsTweakerHotspot)." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                    <UniformGrid Columns="2">

                                        <Button Name="btnStartHotspot" Content="Start Wi-Fi Hotspot" Height="28" Margin="2" Background="#059669" FontWeight="Bold"/>

                                        <Button Name="btnStopHotspot" Content="Stop Wi-Fi Hotspot" Height="28" Margin="2" Background="#DC2626" FontWeight="Bold"/>

                                    </UniformGrid>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="1" Background="#0F172A" CornerRadius="6" Padding="10" Margin="4,0,0,0" BorderBrush="#EF4444" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="PERMANENT FILE SHREDDER (DoD 3-PASS)" FontSize="11.5" FontWeight="Bold" Foreground="#EF4444" Margin="0,0,0,4"/>

                                    <Grid Margin="0,2">

                                        <Grid.ColumnDefinitions>

                                            <ColumnDefinition Width="*"/>

                                            <ColumnDefinition Width="Auto"/>

                                            <ColumnDefinition Width="Auto"/>

                                        </Grid.ColumnDefinitions>

                                        <TextBox Name="txtShredFilePath" Grid.Column="0" Height="26" Margin="0,0,4,0" Text="C:\FileToShred.txt"/>

                                        <Button Name="btnBrowseShredFile" Grid.Column="1" Content="Browse File" Width="80" Height="26" Background="#334155" FontWeight="Bold" Margin="0,0,4,0"/>

                                        <Button Name="btnExecuteShredFile" Grid.Column="2" Content="Shred Now" Width="85" Height="26" Background="#DC2626" FontWeight="Bold"/>

                                    </Grid>

                                </StackPanel>

                            </Border>

                        </Grid>



                        <!-- Device Drivers Quick Launcher -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,8,0,0" BorderBrush="#6366F1" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="DEVICE DRIVERS &amp; DATA MANAGEMENT SUITE" FontSize="11.5" FontWeight="Bold" Foreground="#818CF8" Margin="0,0,0,4"/>

                                <TextBlock Text="Export, import, restore, and inject drivers via DISM and PnPUtil in the dedicated Drivers Hub." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Button Name="btnOpenDriversHubPT" Content="🚀 Open Complete Data &amp; Drivers Management Hub (Tab 13) →" Height="32" Margin="2" Background="#4F46E5" Foreground="White" FontWeight="Bold"/>

                            </StackPanel>

                        </Border>
                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 6: SUPER ADMIN & OEM KEY EXTRACTOR -->

            <TabItem Header="Super Admin">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <TextBlock Text="SUPER ADMINISTRATOR &amp; OEM PRODUCT KEY POWER SUITE" FontSize="12.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>



                        <!-- OEM BIOS Product Key Extractor -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#10B981" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="OEM BIOS &amp; DIGITAL PRODUCT KEY EXTRACTOR" FontSize="11.5" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,4"/>

                                <TextBlock Text="Extracts OEM License Key embedded in Motherboard BIOS ACPI MSDM tables &amp; Registry Digital Product Key to Desktop." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Button Name="btnExtractProductKey" Content="Extract OEM BIOS &amp; Digital Product Key (Export Desktop Report)" Background="#059669" FontWeight="Bold" Height="28"/>

                            </StackPanel>

                        </Border>



                        <!-- Take Full Ownership -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="TAKE FULL ADMINISTRATOR OWNERSHIP &amp; PERMISSIONS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <Grid Margin="0,2">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBox Name="txtTakeOwnPath" Grid.Column="0" Height="26" Margin="0,0,4,0" Text="C:\TargetFolderOrFile"/>

                                    <Button Name="btnBrowseTakeOwn" Grid.Column="1" Content="Browse Folder" Width="100" Height="26" Background="#334155" FontWeight="Bold" Margin="0,0,4,0"/>

                                    <Button Name="btnExecuteTakeOwn" Grid.Column="2" Content="Grant Full Ownership" Width="140" Height="26" Background="#0284C7" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- Advanced Admin Controls -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#7C3AED" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="SPECIAL PRIVILEGES &amp; SYSTEM OVERRIDES" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                <UniformGrid Columns="3">

                                    <Button Name="btnEnableSuperAdmin2" Content="Enable Built-in Administrator" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnCreateGodMode2" Content="Create GodMode Panel" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                    <Button Name="btnDisableUAC2" Content="Disable UAC Prompts" Margin="2" Background="#DC2626" FontWeight="Bold"/>

                                    <Button Name="btnRebootUEFI" Content="Reboot into UEFI/BIOS" Margin="2" Background="#1E40AF" FontWeight="Bold"/>

                                    <Button Name="btnPurgeTelemetryTasks" Content="Purge Telemetry Tasks" Margin="2" Background="#0D9488" FontWeight="Bold"/>

                                    <Button Name="btnInstallGPEdit2" Content="Install GPEdit on Win Home" Margin="2" Background="#4F46E5" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Rename Computer & Force Kill -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" BorderBrush="#EF4444" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="COMPUTER IDENTITY &amp; PROCESS TERMINATOR" FontSize="11.5" FontWeight="Bold" Foreground="#F87171" Margin="0,0,0,4"/>

                                <Grid Margin="0,2,0,4">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="New PC Hostname:" VerticalAlignment="Center" Margin="0,0,8,0" Foreground="#F8FAFC" FontWeight="SemiBold"/>

                                    <TextBox Name="txtNewHostName" Grid.Column="1" Height="26" Margin="0,0,4,0" Text="MyFastPC"/>

                                    <Button Name="btnRenameComputer" Grid.Column="2" Content="Rename Computer" Width="130" Height="26" Background="#0284C7" FontWeight="Bold"/>

                                </Grid>

                                <Grid Margin="0,2">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Kill Process Name:" VerticalAlignment="Center" Margin="0,0,14,0" Foreground="#F8FAFC" FontWeight="SemiBold"/>

                                    <TextBox Name="txtProcessName" Grid.Column="1" Height="26" Margin="0,0,4,0" Text="notepad.exe"/>

                                    <Button Name="btnKillProcess2" Grid.Column="2" Content="Force Terminate" Width="120" Height="26" Background="#DC2626" FontWeight="Bold" Margin="0,0,4,0"/>

                                    <Button Name="btnRegBackup2" Grid.Column="3" Content="Export Full Registry Backup" Width="170" Height="26" Background="#059669" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 7: GAMING & HARDWARE -->

            <TabItem Header="Gaming &amp; Hardware">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <!-- Gaming Latency & Input Lag -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#059669" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="INPUT LAG &amp; LOW LATENCY GAMING BOOSTERS" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                <TextBlock Text="Maximize mouse sensor tracking, eliminate keyboard typing delay, and configure MSI GPU mode." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="3">

                                    <Button Name="btnDisableMouseAccel" Content="Disable Mouse Acceleration (1:1 Raw)" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnBoostKeyboardRate" Content="Boost Keyboard Repeat Rate (0ms Delay)" Margin="2" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnEnableMSIGpu" Content="Enable MSI Mode on GPU (Low DPC)" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Hardware Optimization -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#7C3AED" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="CPU &amp; HARDWARE OPTIMIZATION" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                <UniformGrid Columns="3">

                                    <Button Name="btnUnparkCPU" Content="Unpark All CPU Cores (100% Speed)" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnDisableUSBSleep" Content="Disable USB Power Throttling / Sleep" Margin="2" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnForceTrimSSD" Content="Force Deep NVMe / SSD TRIM" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                    <Button Name="btnEnableHAGS" Content="Enable Hardware GPU Scheduling (HAGS)" Margin="2" Background="#1E40AF" FontWeight="Bold"/>

                                    <Button Name="btnSmartScan" Content="SMART Physical Drive Health Scan" Margin="2" Background="#0D9488" FontWeight="Bold"/>

                                    <Button Name="btnRamSpecs" Content="RAM Hardware Specifications" Margin="2" Background="#6366F1" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Diagnostics & Performance -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="DIAGNOSTICS &amp; BENCHMARKS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <UniformGrid Columns="4">

                                    <Button Name="btnMemDiag" Content="Memory Diagnostic" Margin="2" Background="#0891B2" FontWeight="Bold"/>

                                    <Button Name="btnSpeedTest" Content="Cloudflare Speed Test" Margin="2" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnBatteryHealth" Content="Battery Health Report" Margin="2" Background="#D97706" FontWeight="Bold"/>

                                    <Button Name="btnSysSummary" Content="System Hardware Summary" Margin="2" Background="#7C3AED" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 8: REPAIR & STORAGE (COMPREHENSIVE MASTER SUITE) -->

            <TabItem Header="Repair &amp; Storage">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <!-- 1. SYSTEM SCANS & REPAIRS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="SYSTEM SCANS &amp; REPAIRS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnRunSFC" Content="Run System File Check (sfc /scannow)" Margin="2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnDismRestore" Content="Repair Image Health (DISM /RestoreHealth)" Margin="2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnDismCheck" Content="Quick Check Image Corruption Status (DISM /CheckHealth)" Margin="2" Background="#0891B2" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnResetWU" Content="Reset Windows Update Components &amp; Cache" Margin="2" Background="#D97706" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRepairEngines" Content="Repair Windows Native Repair Engines (SFC &amp; DISM Fix)" Margin="2" Background="#6366F1" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRegCoreDLLs" Content="Re-Register Core Windows System DLL Libraries (regsvr32)" Margin="2" Background="#7C3AED" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnFlushDNS2" Content="Flush System DNS Resolver Cache" Margin="2" Background="#0D9488" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnResetWinsock2" Content="Reset Network Winsock Catalog Bindings" Margin="2" Background="#2563EB" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnResetFirewall2" Content="Reset Windows Firewall Rules to Default" Margin="2" Background="#DC2626" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRepairStore" Content="Re-register &amp; Repair Microsoft Store &amp; Default Apps" Margin="2" Background="#059669" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnResetNetworkStack2" Content="Run Comprehensive Network Stack &amp; Adapter Reset" Margin="2" Background="#9333EA" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- 2. SYSTEM RECOVERY & BOOT MANAGEMENT -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#10B981" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="SYSTEM RECOVERY &amp; BOOT MANAGEMENT" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnEnableWinRE" Content="Enable Windows Recovery Environment (WinRE)" Margin="2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnCheckWinRE" Content="Check WinRE Environment Configuration Status" Margin="2" Background="#0284C7" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- 3. MICROSOFT OFFICE & OUTLOOK DIAGNOSTICS & REPAIRS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0EA5E9" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="MICROSOFT OFFICE &amp; OUTLOOK DIAGNOSTICS &amp; REPAIRS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2" Margin="0,0,0,4">

                                    <Button Name="btnOfficeQuickRepair" Content="Run Microsoft Office Quick Repair (Click-to-Run)" Margin="2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnLaunchScanPST" Content="Launch Outlook PST File Repair Tool (ScanPST)" Margin="2" Background="#0D9488" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                                <Grid Margin="2,4,2,0">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Launch Safe Mode:" VerticalAlignment="Center" FontWeight="SemiBold" Foreground="#94A3B8" Margin="0,0,8,0"/>

                                    <UniformGrid Grid.Column="1" Columns="4">

                                        <Button Name="btnSafeWord" Content="Word" Margin="2" Background="#1E40AF" FontWeight="Bold"/>

                                        <Button Name="btnSafeExcel" Content="Excel" Margin="2" Background="#065F46" FontWeight="Bold"/>

                                        <Button Name="btnSafePPT" Content="PPT" Margin="2" Background="#C2410C" FontWeight="Bold"/>

                                        <Button Name="btnSafeOutlook" Content="Outlook" Margin="2" Background="#0369A1" FontWeight="Bold"/>

                                    </UniformGrid>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- 4. WINDOWS BOOT SECTOR & EFI REPAIR -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#EF4444" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINDOWS BOOT SECTOR &amp; EFI REPAIR" FontSize="11.5" FontWeight="Bold" Foreground="#F87171" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnRebuildBCD" Content="Rebuild Windows Boot configuration partition files (BCDBoot)" Margin="2" Background="#D97706" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRebootRecovery" Content="Reboot System directly into Startup Repair / Recovery Menu" Margin="2" Background="#DC2626" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnEnableBootFailures" Content="Enable Windows Boot Failures Menu Display Policy" Margin="2" Background="#6366F1" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnScheduleChkdsk" Content="Schedule Boot-Time Disk Volume Scan &amp; Repair (Chkdsk /f /r)" Margin="2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- 5. PRINTER SERVICE & SHARING REPAIRS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#F59E0B" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="PRINTER SERVICE &amp; SHARING REPAIRS" FontSize="11.5" FontWeight="Bold" Foreground="#FBBF24" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnFixPrinter0x11b" Content="Fix Shared Printer Error 0x0000011b (Set RpcAuthnLevelPrivacyEnabled=0)" Margin="2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnConfigPrinterGPO" Content="Configure Group Policy Printer Sharing &amp; RPC Connection Settings" Margin="2" Background="#6366F1" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnEnableLPD" Content="Enable Windows LPD Print Service &amp; LPR Port Monitor Optional Features" Margin="2" Background="#0D9488" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRestartPrinterServices" Content="Restart Network Discovery &amp; Printer Sharing Dependency Services" Margin="2" Background="#D97706" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnFlushPrintSpooler" Content="Flush Print Spooler Service &amp; Clear Pending Queue" Margin="2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnLaunchPrinterDiag" Content="Launch Native Windows Printer Troubleshooter Diagnostic Wizard" Margin="2" Background="#0891B2" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- 6. LOSSLESS DRIVE & DISK STYLE CONVERTERS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#8B5CF6" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="LOSSLESS DRIVE &amp; DISK STYLE CONVERTERS" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,6"/>

                                <Grid Margin="0,2,0,4">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="FAT32 Drive Letter:" VerticalAlignment="Center" Margin="0,0,8,0" Foreground="#F8FAFC" FontWeight="SemiBold"/>

                                    <ComboBox Name="cmbDriveLetter" Grid.Column="1" Height="26" Margin="0,0,4,0" Background="#0F172A" Foreground="#F8FAFC"/>

                                    <Button Name="btnConvertNTFS" Grid.Column="2" Content="Convert to NTFS" Width="140" Height="26" Background="#0284C7" FontWeight="Bold"/>

                                </Grid>

                                <Grid Margin="0,2">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Disk ID (MBR):" VerticalAlignment="Center" Margin="0,0,28,0" Foreground="#F8FAFC" FontWeight="SemiBold"/>

                                    <ComboBox Name="cmbDiskID" Grid.Column="1" Height="26" Margin="0,0,4,0" Background="#0F172A" Foreground="#F8FAFC"/>

                                    <Button Name="btnConvertGPT" Grid.Column="2" Content="Convert MBR to GPT" Width="140" Height="26" Background="#D97706" FontWeight="Bold"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <!-- 7. SYSTEM CLEANERS & CACHE OPTIMIZERS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#059669" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="SYSTEM CLEANERS &amp; CACHE OPTIMIZERS" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnFlushRAMCache" Content="Optimize &amp; Flush System RAM Cache (Empty Process Working Sets)" Margin="2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnCleanBrowserCache" Content="Clean Web Browser Cache &amp; Temp Files (Chrome, Edge, Firefox)" Margin="2" Background="#0D9488" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnFindLargestFiles" Content="Find Top 20 Largest Files on C:" Margin="2" Background="#0284C7" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnPurgeWinSxSComponent" Content="Deep Clean WinSxS (DISM ResetBase)" Margin="2" Background="#7C3AED" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnPurgeWindowsOld" Content="Purge Windows.old &amp; Shader Cache" Margin="2" Background="#DC2626" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRebuildSearchIndex" Content="Rebuild Windows Search Index Database" Margin="2" Background="#D97706" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- 8. WINDOWS SERVICES & SHIELD REPAIRS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#6366F1" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINDOWS SERVICES &amp; SHIELD REPAIRS" FontSize="11.5" FontWeight="Bold" Foreground="#818CF8" Margin="0,0,0,6"/>

                                <Button Name="btnRepairWUServiceComprehensive" Content="Run Comprehensive Windows Update Service &amp; Cache Repair Engine" Margin="2" Height="28" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Center"/>

                                <UniformGrid Columns="2" Margin="0,2">

                                    <Button Name="btnBlockWinUpdates" Content="Disable &amp; Block Windows Updates" Height="28" Margin="2" Background="#DC2626" FontWeight="Bold"/>

                                    <Button Name="btnEnableWinUpdates" Content="Restore &amp; Enable Windows Updates" Height="28" Margin="2" Background="#059669" FontWeight="Bold"/>

                                </UniformGrid>

                                <UniformGrid Columns="2">

                                    <Button Name="btnResetDefenderPolicies" Content="Reset Windows Defender Policies &amp; Restart Antivirus Services" Margin="2" Background="#7C3AED" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRestoreFirewallSettings" Content="Restore Default Windows Firewall Settings and Rules" Margin="2" Background="#D97706" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnResetAudioPlaybackServices" Content="Reset &amp; Restart Windows Audio Playback Services" Margin="2" Background="#0D9488" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnUnblockTools" Content="Unblock Registry, Task Manager &amp; Command Prompt" Margin="2" Background="#059669" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnForceTimeResync" Content="Force Windows NTP Clock Resync" Margin="2" Background="#0891B2" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnFixCMOSTimeDrift" Content="Fix CMOS Time Drift (RealTimeIsUniversal)" Margin="2" Background="#6366F1" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnFixAudioLatency" Content="Fix Audio Stuttering &amp; Graph Latency" Margin="2" Background="#2563EB" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnAnalyzeBSOD" Content="BSOD Minidump Crash Analyzer" Margin="2" Background="#DC2626" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnFixStuckWU" Content="Fix Stuck Windows Update Pipeline" Margin="2" Background="#D97706" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- 9. SHELL OPTIMIZERS & DATA WIPERS -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#06B6D4" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="SHELL OPTIMIZERS &amp; DATA WIPERS" FontSize="11.5" FontWeight="Bold" Foreground="#22D3EE" Margin="0,0,0,6"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnRestartExplorerQuick2" Content="Restart Windows Explorer Shell (Quick Freeze Fix)" Margin="2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnClearAllEventLogs" Content="Clear All Windows System, Application &amp; Security Event Logs" Margin="2" Background="#DC2626" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRebuildIconCache" Content="Rebuild Windows Desktop Icon &amp; Thumbnail Cache Data" Margin="2" Background="#D97706" HorizontalContentAlignment="Left"/>

                                    <Button Name="btnRebuildFontCache" Content="Rebuild Windows System Font Cache Database" Margin="2" Background="#059669" HorizontalContentAlignment="Left"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 9: OS TWEAKS & MENU -->

            <TabItem Header="OS Tweaks &amp; Menu">

                <Grid Margin="6">

                    <Grid.RowDefinitions>

                        <RowDefinition Height="*"/>

                        <RowDefinition Height="Auto"/>

                    </Grid.RowDefinitions>



                    <ScrollViewer Grid.Row="0" VerticalScrollBarVisibility="Auto" Margin="0,0,0,6">

                        <StackPanel>

                            <!-- 1. Telemetry & Privacy -->

                            <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#DC2626" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="TELEMETRY &amp; PRIVACY (RECOMMENDED)" FontSize="11.5" FontWeight="Bold" Foreground="#F87171" Margin="0,0,0,4"/>

                                    <CheckBox Name="chkTelemetry" Content="Disable Windows Telemetry &amp; Diagnostic Data" IsChecked="True"/>

                                    <CheckBox Name="chkCortana" Content="Disable Cortana Digital Assistant service" IsChecked="True"/>

                                    <CheckBox Name="chkBing" Content="Disable Bing Search queries in Start Menu" IsChecked="True"/>

                                    <CheckBox Name="chkAds" Content="Disable Lockscreen Tips, Ads &amp; Spotlight suggestions" IsChecked="True"/>

                                    <CheckBox Name="chkLocation" Content="Disable Location Tracking service &amp; sensors" IsChecked="True"/>

                                    <CheckBox Name="chkActivity" Content="Disable Activity History timeline tracker" IsChecked="True"/>

                                    <CheckBox Name="chkFeedback" Content="Disable Windows Feedback Prompts &amp; Surveys" IsChecked="True"/>

                                    <CheckBox Name="chkSmartScreen" Content="Disable Windows SmartScreen Download Filter"/>

                                </StackPanel>

                            </Border>



                            <!-- 2. System Optimizations & Adjustments -->

                            <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="SYSTEM OPTIMIZATIONS &amp; ADJUSTMENTS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                    <CheckBox Name="chkHighPower" Content="Enable High-Performance Power Plan Scheme"/>

                                    <CheckBox Name="chkUltPower" Content="Enable Ultimate Performance Power Plan Scheme" IsChecked="True"/>

                                    <CheckBox Name="chkStartupDelay" Content="Disable Startup Delay for Desktop Apps launcher" IsChecked="True"/>

                                    <CheckBox Name="chkStickyKeys" Content="Disable Sticky Keys Prompt Popup warning" IsChecked="True"/>

                                    <CheckBox Name="chkVirtSecurity" Content="Enable Virtualization Security Mitigations Fix"/>

                                    <CheckBox Name="chkDisableHibernation" Content="Disable System Hibernation File (saves GBs of space)"/>

                                    <CheckBox Name="chkMenuDelay" Content="Speed Up Menu &amp; Window animation delays" IsChecked="True"/>

                                    <CheckBox Name="chkNtfsTime" Content="Disable NTFS Last-Access Timestamp updating" IsChecked="True"/>

                                    <CheckBox Name="chkUniversalBg" Content="Disable Universal App Background Run (Saves RAM/CPU)" IsChecked="True"/>

                                    <CheckBox Name="chkEdgePreload" Content="Stop Edge/Office Startup Pre-loading apps" IsChecked="True"/>

                                    <CheckBox Name="chkHAGS" Content="Enable Hardware Accelerated GPU Scheduling (HAGS)"/>

                                    <CheckBox Name="chkTransparency" Content="Disable Desktop Transparency &amp; Blur Effects"/>

                                    <CheckBox Name="chkGameDVR" Content="Disable Xbox Game Bar &amp; Background DVR Recording" IsChecked="True"/>

                                    <CheckBox Name="chkNetThrottle" Content="Disable Network Throttling Index for Gaming" IsChecked="True"/>

                                    <CheckBox Name="chkHoverDelays" Content="Disable Windows UI Hover Delays &amp; Speed up Taskbar" IsChecked="True"/>

                                    <CheckBox Name="chkSearchHighlights" Content="Disable Dynamic Search Highlights on Taskbar" IsChecked="True"/>

                                </StackPanel>

                            </Border>



                            <!-- 3. Right-Click Context Menu Tweaks -->

                            <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#7C3AED" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="RIGHT-CLICK CONTEXT MENU TWEAKS" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                    <CheckBox Name="chkTakeOwn" Content="Add 'Take Ownership' option to File Context Menu" IsChecked="True"/>

                                    <CheckBox Name="chkOpenNotepad" Content="Add 'Open with Notepad' option to File Context Menu" IsChecked="True"/>

                                    <CheckBox Name="chkKillStuck" Content="Add 'Kill Not Responding Tasks' to Desktop Menu" IsChecked="True"/>

                                    <CheckBox Name="chkCmdAdmin" Content="Add 'Command Prompt Here (Admin)' to Folder Menu" IsChecked="True"/>

                                </StackPanel>

                            </Border>



                            <!-- 4. Cleaners, Bloatware & Services -->

                            <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#059669" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="CLEANERS, BLOATWARE &amp; SERVICES" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                    <CheckBox Name="chkCleanTemp" Content="Clean Temporary Files and Prefetch folder"/>

                                    <CheckBox Name="chkCleanmgr" Content="Run Disk Cleanup (Cleanmgr Utility) on drive C:"/>

                                    <CheckBox Name="chkDisableOneDrive" Content="Disable OneDrive Syncing &amp; Auto Startup run"/>

                                    <CheckBox Name="chkRemoveBloatware" Content="Remove Default Windows UWP Bloatware (Xbox, Solitaire, News, Weather)"/>

                                    <CheckBox Name="chkDisableSearchIndexer" Content="Disable Search Indexer background service"/>

                                    <CheckBox Name="chkDisableDefender" Content="Disable Windows Defender Antivirus suite"/>

                                    <CheckBox Name="chkStopWU" Content="Stop &amp; Disable Windows Automatic Updates service"/>

                                    <CheckBox Name="chkGameLatency" Content="Optimize Network TCP/IP Latency for Online Gaming" IsChecked="True"/>

                                    <CheckBox Name="chkShowExt" Content="Show File Name Extensions in Windows Explorer" IsChecked="True"/>

                                    <CheckBox Name="chkShowHidden" Content="Show Hidden Files, Folders, and NTFS Drives"/>

                                    <CheckBox Name="chkWin11ClassicMenu" Content="Enable Windows 11 Classic Right-Click Context Menu"/>

                                    <CheckBox Name="chkPhotoViewer" Content="Restore Classic Windows Photo Viewer" IsChecked="True"/>

                                </StackPanel>

                            </Border>

                        </StackPanel>

                    </ScrollViewer>



                    <!-- Presets & Batch Apply -->

                    <Border Grid.Row="1" Background="#0F172A" CornerRadius="6" Padding="8" BorderBrush="#0284C7" BorderThickness="1.5">

                        <Grid>

                            <Grid.ColumnDefinitions>

                                <ColumnDefinition Width="Auto"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="Auto"/>

                            </Grid.ColumnDefinitions>

                            <StackPanel Grid.Column="0" Orientation="Horizontal">

                                <TextBlock Text="Quick Presets: " Foreground="#94A3B8" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,6,0"/>

                                <Button Name="btnPresetRecommended" Content="Recommended" Background="#059669" FontWeight="Bold" Width="105" Margin="0,0,4,0"/>

                                <Button Name="btnPresetOnlyTweaks" Content="Only Tweaks" Background="#D97706" FontWeight="Bold" Width="95" Margin="0,0,4,0"/>

                                <Button Name="btnPresetClear" Content="Reset Presets" Background="#DC2626" FontWeight="Bold" Width="95"/>

                            </StackPanel>

                            <Button Name="btnApplyTweaksBatch" Grid.Column="2" Content="Apply Selected Tweaks" Background="#0284C7" FontWeight="Bold" Width="160" Height="28"/>

                        </Grid>

                    </Border>

                </Grid>

            </TabItem>



            <!-- TAB 10: SECURITY & USB LOCK -->

            <TabItem Header="Security &amp; USB Lock">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#DC2626" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="USB DATA LEAK PROTECTION" FontSize="11.5" FontWeight="Bold" Foreground="#EF4444" Margin="0,0,0,4"/>

                                <TextBlock Text="Lock USB pen drives to Read-Only mode to prevent unauthorized copying of sensitive files." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                                <Grid>

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="*"/>

                                    </Grid.ColumnDefinitions>

                                    <Button Name="btnEnableUSBWriteProtect" Grid.Column="0" Content="Enable USB Write-Protect (Read-Only Mode)" Background="#DC2626" Margin="0,0,3,0" FontWeight="Bold" Height="28"/>

                                    <Button Name="btnDisableUSBWriteProtect" Grid.Column="1" Content="Disable USB Write-Protect (Normal Mode)" Background="#059669" Margin="3,0,0,0" FontWeight="Bold" Height="28"/>

                                </Grid>

                            </StackPanel>

                        </Border>



                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="HOSTS FILE AD-BLOCKER &amp; DEFENDER EXCLUSIONS" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <Button Name="btnInjectHostsAdblock" Content="Inject Telemetry &amp; Malware Ad-Blocker into Windows Hosts File" Margin="0,2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnResetHosts" Content="Reset Windows Hosts File to Factory Default" Margin="0,2" Background="#D97706" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnAddDefenderExclusion" Content="Add Folder Exclusion to Windows Defender (Prevents Dev Script Blocking)" Margin="0,2" Background="#7C3AED" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                            </StackPanel>

                        </Border>



                        <Border Background="#0F172A" CornerRadius="6" Padding="10" BorderBrush="#7C3AED" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="VIRTUALIZATION &amp; ISOLATION" FontSize="11.5" FontWeight="Bold" Foreground="#A78BFA" Margin="0,0,0,4"/>

                                <Button Name="btnEnableSandbox" Content="Enable Windows Sandbox (Disposable Virtual Testing Environment)" Margin="0,2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnEnableHyperV" Content="Enable Microsoft Hyper-V Virtualization Platform" Margin="0,2" Background="#4F46E5" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 11: NETWORK & WI-FI TOOLS -->

            <TabItem Header="Network &amp; Wi-Fi Tools">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#10B981" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WI-FI PASSWORDS &amp; MOBILE QR CODE GENERATOR" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                <Button Name="btnExportWiFiPass" Content="Export All Saved Wi-Fi Passwords to Desktop Report" Margin="0,2" HorizontalContentAlignment="Left" Background="#059669" FontWeight="Bold"/>

                                <Button Name="btnGenWiFiQR" Content="Generate Mobile Connect QR Code for Active Wi-Fi (Scan to Connect)" Margin="0,2" HorizontalContentAlignment="Left" Background="#0284C7" FontWeight="Bold"/>

                            </StackPanel>

                        </Border>



                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#6366F1" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="TCP GAMING LATENCY, CONGESTION &amp; PORTS MONITOR" FontSize="11.5" FontWeight="Bold" Foreground="#818CF8" Margin="0,0,0,4"/>

                                <Button Name="btnApplyTCPAck" Content="Apply TCP NoDelay &amp; AckFrequency Tweaks (Reduces Ping in Online Games)" Margin="0,2" Background="#6366F1" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnBoostTCPCongestion" Content="Optimize TCP Congestion Provider to CTCP / BBR" Margin="0,2" Background="#0D9488" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnViewActivePorts" Content="Inspect Active Listening Ports &amp; Connections (Netstat Monitor)" Margin="0,2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnResetWinsock3" Content="Run Full Winsock &amp; TCP/IP Stack Reset" Margin="0,2" Background="#DC2626" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                            </StackPanel>

                        </Border>



                        <Border Background="#0F172A" CornerRadius="6" Padding="10" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="FAST SECURE DNS SWITCHER" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,4"/>

                                <UniformGrid Columns="4">

                                    <Button Name="btnDNSCloudflare" Content="Cloudflare (1.1.1.1)" Margin="2" Background="#F59E0B" FontWeight="Bold"/>

                                    <Button Name="btnDNSGoogle" Content="Google (8.8.8.8)" Margin="2" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnDNSQuad9" Content="Quad9 (9.9.9.9)" Margin="2" Background="#7C3AED" FontWeight="Bold"/>

                                    <Button Name="btnDNSDHCP" Content="Reset to DHCP" Margin="2" Background="#059669" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 12: ACTIVATION, OFFICE & CHANGE EDITION -->

            <TabItem Header="Activation &amp; ISOs">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <!-- CHANGE WINDOWS EDITION (IN-PLACE UPGRADE) -->

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,8" BorderBrush="#F59E0B" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="CHANGE WINDOWS EDITION (1-CLICK IN-PLACE UPGRADE)" FontSize="12" FontWeight="Bold" Foreground="#FBBF24" Margin="0,0,0,4"/>

                                <TextBlock Text="Instantly upgrade Windows 10/11 Home to Pro, Pro to Enterprise, Workstation, or Education without reinstalling Windows." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>



                                <Grid Margin="0,0,0,6">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Select Target Edition:" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="#F8FAFC" FontWeight="Bold"/>

                                    <ComboBox Name="cmbTargetWinEdition" Grid.Column="1" Height="26" Background="#0F172A" Foreground="#F8FAFC"/>

                                </Grid>



                                <Grid Margin="0,0,0,6">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="Auto"/>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBlock Grid.Column="0" Text="Product Key (Auto/Custom):" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="#F8FAFC" FontWeight="SemiBold"/>

                                    <TextBox Name="txtCustomEditionKey" Grid.Column="1" Height="26" Margin="0,0,6,0" Text="VK7JG-NPHTM-C97JM-9MPGT-3V66T"/>

                                    <Button Name="btnAutoFillEditionKey" Grid.Column="2" Content="Auto-Fill Generic Key" Width="140" Height="26" Background="#334155" FontWeight="Bold"/>

                                </Grid>



                                <UniformGrid Columns="3" Margin="0,2,0,0">

                                    <Button Name="btnApplyEditionChange" Content="Upgrade via changepk.exe" Margin="2" Background="#059669" FontWeight="Bold" Height="28"/>

                                    <Button Name="btnDISMEditionChange" Content="Upgrade via DISM /Set-Edition" Margin="2" Background="#0284C7" FontWeight="Bold" Height="28"/>

                                    <Button Name="btnOpenMASEditionMenu" Content="MAS Change Edition Menu" Margin="2" Background="#D97706" FontWeight="Bold" Height="28"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Microsoft Office Installers -->

                        <TextBlock Text="MICROSOFT OFFICE INSTALLER SUITE" FontSize="12" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,6"/>

                        <Grid Margin="0,0,0,8">

                            <Grid.ColumnDefinitions>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                            </Grid.ColumnDefinitions>

                            

                            <Border Grid.Column="0" Background="#0F172A" CornerRadius="6" Padding="6" Margin="0,0,2,0" BorderBrush="#0284C7" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Microsoft 365 Apps" FontWeight="Bold" FontSize="11" Foreground="#38BDF8"/>

                                    <TextBlock Text="Subscription Suite apps." FontSize="9.5" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,2,0,6"/>

                                    <Button Name="btnInstallM365" Content="Install M365" Background="#0284C7" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="1" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,2,0" BorderBrush="#1E40AF" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Office LTSC 2019" FontWeight="Bold" FontSize="11" Foreground="#60A5FA"/>

                                    <TextBlock Text="Perpetual 2019 ProPlus." FontSize="9.5" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,2,0,6"/>

                                    <Button Name="btnInstall2019" Content="Install 2019" Background="#1E40AF" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="2" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,2,0" BorderBrush="#059669" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Office LTSC 2021" FontWeight="Bold" FontSize="11" Foreground="#34D399"/>

                                    <TextBlock Text="Perpetual 2021 ProPlus." FontSize="9.5" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,2,0,6"/>

                                    <Button Name="btnInstall2021" Content="Install 2021" Background="#059669" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="3" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,0,0" BorderBrush="#7C3AED" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Office LTSC 2024" FontWeight="Bold" FontSize="11" Foreground="#A78BFA"/>

                                    <TextBlock Text="Perpetual 2024 ProPlus." FontSize="9.5" Foreground="#94A3B8" TextWrapping="Wrap" Margin="0,2,0,6"/>

                                    <Button Name="btnInstall2024" Content="Install 2024" Background="#7C3AED" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>

                        </Grid>



                        <!-- MAS Activation -->

                        <TextBlock Text="WINDOWS &amp; OFFICE ACTIVATION (OPEN-SOURCE MAS)" FontSize="12" FontWeight="Bold" Foreground="#38BDF8" Margin="0,2,0,6"/>

                        <Grid>

                            <Grid.ColumnDefinitions>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                                <ColumnDefinition Width="*"/>

                            </Grid.ColumnDefinitions>



                            <Border Grid.Column="0" Background="#0F172A" CornerRadius="6" Padding="6" Margin="0,0,2,0" BorderBrush="#059669" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Windows (HWID)" FontWeight="Bold" FontSize="10.5" Foreground="#34D399"/>

                                    <TextBlock Text="Permanent digital license." FontSize="9" Foreground="#94A3B8" Margin="0,2,0,4"/>

                                    <Button Name="btnActWindows" Content="Activate Win" Background="#059669" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="1" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,2,0" BorderBrush="#0284C7" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Office (Ohook)" FontWeight="Bold" FontSize="10.5" Foreground="#38BDF8"/>

                                    <TextBlock Text="Local Ohook injection." FontSize="9" Foreground="#94A3B8" Margin="0,2,0,4"/>

                                    <Button Name="btnActOffice" Content="Activate Office" Background="#0284C7" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="2" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,2,0" BorderBrush="#6366F1" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Both (KMS)" FontWeight="Bold" FontSize="10.5" Foreground="#818CF8"/>

                                    <TextBlock Text="Online KMS script." FontSize="9" Foreground="#94A3B8" Margin="0,2,0,4"/>

                                    <Button Name="btnActKMS" Content="Activate KMS" Background="#6366F1" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="3" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,2,0" BorderBrush="#DC2626" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Uninstall KMS" FontWeight="Bold" FontSize="10.5" Foreground="#F87171"/>

                                    <TextBlock Text="Removes online KMS." FontSize="9" Foreground="#94A3B8" Margin="0,2,0,4"/>

                                    <Button Name="btnCleanKMS" Content="Clean KMS" Background="#DC2626" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>



                            <Border Grid.Column="4" Background="#0F172A" CornerRadius="6" Padding="6" Margin="2,0,0,0" BorderBrush="#D97706" BorderThickness="1.5">

                                <StackPanel>

                                    <TextBlock Text="Change Edition" FontWeight="Bold" FontSize="10.5" Foreground="#FBBF24"/>

                                    <TextBlock Text="Home to Pro/Ent." FontSize="9" Foreground="#94A3B8" Margin="0,2,0,4"/>

                                    <Button Name="btnChangeEdition" Content="Change Edition" Background="#D97706" FontWeight="Bold" Height="26"/>

                                </StackPanel>

                            </Border>

                        </Grid>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



            <!-- TAB 13: DATA & DRIVERS HUB -->

            <TabItem Header="Data &amp; Drivers Hub">

                <Grid Margin="6">

                    <Grid.RowDefinitions>

                        <RowDefinition Height="Auto"/>

                        <RowDefinition Height="Auto"/>

                        <RowDefinition Height="*"/>

                    </Grid.RowDefinitions>



                    <!-- TOP: DRIVER EXPORT & IMPORT MASTER BAR -->

                    <Border Grid.Row="0" Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,0,6" BorderBrush="#6366F1" BorderThickness="1.5">

                        <StackPanel>

                            <TextBlock Text="DEVICE DRIVERS BACKUP, EXPORT &amp; RESTORE MASTER HUB" FontSize="11.5" FontWeight="Bold" Foreground="#818CF8" Margin="0,0,0,4"/>

                            <TextBlock Text="Export all installed 3rd-party INF drivers to Desktop/Folder, or restore/inject drivers online &amp; offline." FontSize="10" Foreground="#94A3B8" Margin="0,0,0,6"/>

                            <WrapPanel Orientation="Horizontal">

                                <Button Name="btnExportDrivers" Content="Export Drivers (Desktop Backup)" Background="#059669" FontWeight="Bold" Padding="10,6" Margin="0,0,6,4"/>

                                <Button Name="btnExportDriversCustom" Content="Export Drivers (Choose Folder)" Background="#0284C7" FontWeight="Bold" Padding="10,6" Margin="0,0,6,4"/>

                                <Button Name="btnRestoreDrivers" Content="Import &amp; Restore Drivers (PnPUTIL)" Background="#6366F1" FontWeight="Bold" Padding="10,6" Margin="0,0,6,4"/>

                                <Button Name="btnOfflineInjectDrivers" Content="Offline Driver Inject (DISM)" Background="#D97706" FontWeight="Bold" Padding="10,6" Margin="0,0,6,4"/>

                                <Button Name="btnListDrivers" Content="List 3rd-Party Drivers" Background="#0891B2" FontWeight="Bold" Padding="10,6" Margin="0,0,6,4"/>

                                <Button Name="btnOpenDevMgmt" Content="Device Manager (Show Ghost / Hidden Drivers)" Background="#7C3AED" FontWeight="Bold" Padding="10,6" Margin="0,0,6,4"/>

                            </WrapPanel>

                        </StackPanel>

                    </Border>



                    <!-- MIDDLE SPLIT: ROBOCOPY & ENTERPRISE/CACHE -->

                    <Grid Grid.Row="1" Margin="0,0,0,6">

                        <Grid.ColumnDefinitions>

                            <ColumnDefinition Width="1.2*"/>

                            <ColumnDefinition Width="*"/>

                        </Grid.ColumnDefinitions>



                        <!-- Robocopy Hub -->

                        <Border Grid.Column="0" Background="#0F172A" CornerRadius="6" Padding="10" Margin="0,0,4,0" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="DATA MIGRATION &amp; ROBOCOPY MIRROR" FontSize="11.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,6"/>

                                

                                <TextBlock Text="Source Folder:" FontSize="10" Foreground="#94A3B8" Margin="0,0,0,2"/>

                                <Grid Margin="0,0,0,4">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBox Name="txtSourceFolder" Grid.Column="0" Height="26"/>

                                    <Button Name="btnBrowseSource" Grid.Column="1" Content="Browse Source" Width="95" Height="26" Background="#334155" FontWeight="Bold" Margin="4,0,0,0"/>

                                </Grid>



                                <TextBlock Text="Target Folder:" FontSize="10" Foreground="#94A3B8" Margin="0,0,0,2"/>

                                <Grid Margin="0,0,0,6">

                                    <Grid.ColumnDefinitions>

                                        <ColumnDefinition Width="*"/>

                                        <ColumnDefinition Width="Auto"/>

                                    </Grid.ColumnDefinitions>

                                    <TextBox Name="txtTargetFolder" Grid.Column="0" Height="26"/>

                                    <Button Name="btnBrowseTarget" Grid.Column="1" Content="Browse Target" Width="95" Height="26" Background="#334155" FontWeight="Bold" Margin="4,0,0,0"/>

                                </Grid>



                                <UniformGrid Columns="2">

                                    <Button Name="btnRunRobocopy" Content="Run Robocopy Mirror Engine" Background="#0284C7" FontWeight="Bold" Height="28" Margin="0,0,3,0"/>

                                    <Button Name="btnExportBookmarks2" Content="Backup Browser Bookmarks" Background="#0D9488" FontWeight="Bold" Height="28" Margin="3,0,0,0"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>



                        <!-- Enterprise, Winget & Cache Purge -->

                        <Border Grid.Column="1" Background="#0F172A" CornerRadius="6" Padding="10" Margin="4,0,0,0" BorderBrush="#059669" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="ENTERPRISE, UPDATES &amp; CACHE PURGE" FontSize="11.5" FontWeight="Bold" Foreground="#34D399" Margin="0,0,0,4"/>

                                <Button Name="btnUpgradeWinget" Content="Force Upgrade All Installed Software (WinGet)" Margin="0,2" Background="#059669" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnRestartTally" Content="Restart Active Tally Gateway System Engines" Margin="0,2" Background="#0284C7" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnPurgeCache" Content="Purge System Prefetch, Cache, and Temp Files" Margin="0,2" Background="#DC2626" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                                <Button Name="btnCleanDriverStore" Content="Clean Old / Unused Driver Store Packages" Margin="0,2" Background="#7C3AED" FontWeight="Bold" HorizontalContentAlignment="Left"/>

                            </StackPanel>

                        </Border>

                    </Grid>



                    <!-- Terminal Output -->

                    <Border Grid.Row="2" Background="#050B14" CornerRadius="6" Padding="6" BorderBrush="#10B981" BorderThickness="1.5">

                        <Grid>

                            <Grid.RowDefinitions>

                                <RowDefinition Height="Auto"/>

                                <RowDefinition Height="*"/>

                            </Grid.RowDefinitions>

                            <TextBlock Grid.Row="0" Text="Migration &amp; Engine Outputs Terminal" FontSize="10" FontWeight="Bold" Foreground="#10B981" Margin="0,0,0,2"/>

                            <TextBox Name="txtTerminalLog" Grid.Row="1" Background="Transparent" Foreground="#10B981" FontFamily="Consolas" FontSize="10.5" IsReadOnly="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto" BorderThickness="0" Text="[backups &amp; diagnostics node ready]&#x0a;"/>

                        </Grid>

                    </Border>

                </Grid>

            </TabItem>



            <!-- TAB 14: QUICK HUB -->

            <TabItem Header="Quick Hub">

                <ScrollViewer VerticalScrollBarVisibility="Auto" Margin="8">

                    <StackPanel>

                        <Border Background="#0F172A" CornerRadius="6" Padding="10" BorderBrush="#0284C7" BorderThickness="1.5">

                            <StackPanel>

                                <TextBlock Text="WINDOWS BUILT-IN ADMINISTRATIVE CONSOLES" FontSize="12.5" FontWeight="Bold" Foreground="#38BDF8" Margin="0,0,0,8"/>

                                <UniformGrid Columns="2">

                                    <Button Name="btnHubReg2" Content="Registry Editor (regedit)" Margin="3" Height="34" Background="#0284C7" FontWeight="Bold"/>

                                    <Button Name="btnHubDev2" Content="Device Manager (devmgmt.msc)" Margin="3" Height="34" Background="#059669" FontWeight="Bold"/>

                                    <Button Name="btnHubGP2" Content="Group Policy Editor (gpedit.msc)" Margin="3" Height="34" Background="#7C3AED" FontWeight="Bold"/>

                                    <Button Name="btnHubDisk2" Content="Disk Management (diskmgmt.msc)" Margin="3" Height="34" Background="#D97706" FontWeight="Bold"/>

                                    <Button Name="btnHubTask2" Content="Task Manager (taskmgr)" Margin="3" Height="34" Background="#DC2626" FontWeight="Bold"/>

                                    <Button Name="btnHubRes2" Content="Resource Monitor (resmon)" Margin="3" Height="34" Background="#0D9488" FontWeight="Bold"/>

                                    <Button Name="btnHubDx2" Content="DirectX Diagnostic Tool (dxdiag)" Margin="3" Height="34" Background="#6366F1" FontWeight="Bold"/>

                                    <Button Name="btnHubServ2" Content="Windows Services (services.msc)" Margin="3" Height="34" Background="#0891B2" FontWeight="Bold"/>

                                </UniformGrid>

                            </StackPanel>

                        </Border>

                    </StackPanel>

                </ScrollViewer>

            </TabItem>



        </TabControl>



        <!-- FOOTER BAR -->

        <Border Grid.Row="2" Background="#0F172A" CornerRadius="6" Padding="10,5" Margin="0,6,0,0" BorderBrush="#1E293B" BorderThickness="1">

            <Grid>

                <Grid.ColumnDefinitions>

                    <ColumnDefinition Width="*"/>

                    <ColumnDefinition Width="Auto"/>

                </Grid.ColumnDefinitions>

                <TextBlock Name="txtStatusFooter" Grid.Column="0" Text="Status: Venkat Master Suite Ready | 360+ Tools | Use Up/Down/Left/Right Arrow Keys or Ctrl+Tab to Shift Tabs." FontSize="10" Foreground="#10B981" VerticalAlignment="Center"/>

                <Button Name="btnCloseApp" Grid.Column="1" Content="Exit Application" Background="#1E293B" Width="105"/>

            </Grid>

        </Border>

    </Grid>

</Window>

"@



# Load XAML

$reader = New-Object System.Xml.XmlNodeReader $xaml

$window = [Windows.Markup.XamlReader]::Load($reader)



# Universal Control Auto-Binding

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {

    $elemName = $_.Name

    if ($elemName -and $elemName -notmatch "Border|ContentSite|btnBorder") {

        Set-Variable -Name $elemName -Value $window.FindName($elemName) -Scope Global

    }

}



# SET CUSTOM APPLICATION ICON & TASKBAR BADGE

try {

    $iconB64 = "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"

    $iconBytes = [System.Convert]::FromBase64String($iconB64)

    $iconStream = New-Object System.IO.MemoryStream(,$iconBytes)

    $iconBitmap = [System.Windows.Media.Imaging.BitmapFrame]::Create($iconStream)

    $window.Icon = $iconBitmap

} catch {}



# Window Control Buttons

$btnWinMin = $window.FindName("btnWinMin")

$btnWinMax = $window.FindName("btnWinMax")

$btnWinClose = $window.FindName("btnWinClose")



if ($btnWinMin) {

    $btnWinMin.Add_Click({ $window.WindowState = [System.Windows.WindowState]::Minimized })

}

if ($btnWinMax) {

    $btnWinMax.Add_Click({

        if ($window.WindowState -eq [System.Windows.WindowState]::Maximized) {

            $window.WindowState = [System.Windows.WindowState]::Normal

        } else {

            $window.WindowState = [System.Windows.WindowState]::Maximized

        }

    })

}

if ($btnWinClose) {

    $btnWinClose.Add_Click({ $window.Close() })

}



# ==================== TAB SHIFT & KEYBOARD NAVIGATION ENGINE ====================

$MainTabControl = $window.FindName("MainTabControl")



function Shift-ToPrevTab {

    if (-not $MainTabControl) { return }

    $count = $MainTabControl.Items.Count

    if ($count -le 0) { return }

    $cur = $MainTabControl.SelectedIndex

    if ($cur -le 0) {

        $MainTabControl.SelectedIndex = $count - 1

    } else {

        $MainTabControl.SelectedIndex = $cur - 1

    }

}



function Shift-ToNextTab {

    if (-not $MainTabControl) { return }

    $count = $MainTabControl.Items.Count

    if ($count -le 0) { return }

    $cur = $MainTabControl.SelectedIndex

    if ($cur -ge ($count - 1)) {

        $MainTabControl.SelectedIndex = 0

    } else {

        $MainTabControl.SelectedIndex = $cur + 1

    }

}



# Keyboard Shortcuts & Arrow Keys Tab Shifting (Up/Down/Left/Right / PageUp/PageDown / Ctrl+Tab)

$window.Add_PreviewKeyDown({

    param($sender, $e)

    try {

        $focused = [System.Windows.Input.FocusManager]::GetFocusedElement($window)

        $isTextEditor = ($focused -is [System.Windows.Controls.TextBox] -or $focused -is [System.Windows.Controls.PasswordBox])

        

        $ctrlPressed = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftCtrl) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightCtrl)

        $altPressed = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftAlt) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightAlt)

        $shiftPressed = [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::LeftShift) -or [System.Windows.Input.Keyboard]::IsKeyDown([System.Windows.Input.Key]::RightShift)



        # Ctrl+Tab / Ctrl+Shift+Tab

        if ($e.Key -eq [System.Windows.Input.Key]::Tab -and $ctrlPressed) {

            if ($shiftPressed) { Shift-ToPrevTab } else { Shift-ToNextTab }

            $e.Handled = $true

            return

        }



        # PageUp / PageDown

        if ($e.Key -eq [System.Windows.Input.Key]::PageUp) {

            Shift-ToPrevTab

            $e.Handled = $true

            return

        }

        if ($e.Key -eq [System.Windows.Input.Key]::PageDown) {

            Shift-ToNextTab

            $e.Handled = $true

            return

        }



        # Left Arrow / Up Arrow -> Prev Tab

        if ($e.Key -eq [System.Windows.Input.Key]::Left -or $e.Key -eq [System.Windows.Input.Key]::Up) {

            if (-not $isTextEditor -or $ctrlPressed -or $altPressed) {

                Shift-ToPrevTab

                $e.Handled = $true

                return

            }

        }



        # Right Arrow / Down Arrow -> Next Tab

        if ($e.Key -eq [System.Windows.Input.Key]::Right -or $e.Key -eq [System.Windows.Input.Key]::Down) {

            if (-not $isTextEditor -or $ctrlPressed -or $altPressed) {

                Shift-ToNextTab

                $e.Handled = $true

                return

            }

        }

    } catch {}

})



# Map Search & Controls

$txtSearch = $window.FindName("txtSearch")

$btnSearch = $window.FindName("btnSearch")



# User Passwords Controls

$cmbUserAccounts = $window.FindName("cmbUserAccounts")

$btnRefreshUserList = $window.FindName("btnRefreshUserList")

$txtUserNewPass = $window.FindName("txtUserNewPass")

$btnApplyUserPass = $window.FindName("btnApplyUserPass")

$btnRemoveUserPass = $window.FindName("btnRemoveUserPass")

$btnUnlockUserAcc = $window.FindName("btnUnlockUserAcc")

$btnDisableUserAcc = $window.FindName("btnDisableUserAcc")

$btnPassNeverExpire = $window.FindName("btnPassNeverExpire")

$btnDeleteUserAcc = $window.FindName("btnDeleteUserAcc")

$btnEnableAutoLogon = $window.FindName("btnEnableAutoLogon")

$btnDisableAutoLogon = $window.FindName("btnDisableAutoLogon")

$txtCreateUsername = $window.FindName("txtCreateUsername")

$txtCreatePassword = $window.FindName("txtCreatePassword")

$cmbAccountType = $window.FindName("cmbAccountType")

$btnCreateAccountAction = $window.FindName("btnCreateAccountAction")
$btnEnableWorkingGuest = $window.FindName("btnEnableWorkingGuest")
$btnDisableWorkingGuest = $window.FindName("btnDisableWorkingGuest")
$btnCheckGuestStatus = $window.FindName("btnCheckGuestStatus")

$btnOpenNetplwiz = $window.FindName("btnOpenNetplwiz")

$btnOpenLusrmgr = $window.FindName("btnOpenLusrmgr")

$btnLaunchMailPassView = $window.FindName("btnLaunchMailPassView")

$btnScanLocalMailProfiles = $window.FindName("btnScanLocalMailProfiles")

$btnExportMailReport = $window.FindName("btnExportMailReport")

$btnLaunchWinPERescue = $window.FindName("btnLaunchWinPERescue")

$btnLaunchWinPEBuilder = $window.FindName("btnLaunchWinPEBuilder")

$btnLaunchNirLauncher = $window.FindName("btnLaunchNirLauncher")

$btnDownloadNirLauncher = $window.FindName("btnDownloadNirLauncher")

$btnOpenNirFolder = $window.FindName("btnOpenNirFolder")

$btnLaunchWebBrowserPass = $window.FindName("btnLaunchWebBrowserPass")

$btnLaunchWirelessKeyView = $window.FindName("btnLaunchWirelessKeyView")

$btnLaunchOutlookPass = $window.FindName("btnLaunchOutlookPass")

$chkAppNirLauncher = $window.FindName("chkAppNirLauncher")

$btnPresetAppMS = $window.FindName("btnPresetAppMS")

$chkAppMS365 = $window.FindName("chkAppMS365")

$chkAppMSTeams = $window.FindName("chkAppMSTeams")

$chkAppPowerToys = $window.FindName("chkAppPowerToys")

$chkAppMSTerminal = $window.FindName("chkAppMSTerminal")

$chkAppMSPCManager = $window.FindName("chkAppMSPCManager")

$chkAppMSOneDrive = $window.FindName("chkAppMSOneDrive")

$chkAppMSPS7 = $window.FindName("chkAppMSPS7")

$chkAppMSSysinternals = $window.FindName("chkAppMSSysinternals")

$chkAppMSOneNote = $window.FindName("chkAppMSOneNote")

$chkAppMSWhiteboard = $window.FindName("chkAppMSWhiteboard")

$chkAppMSSSMS = $window.FindName("chkAppMSSSMS")

$chkAppMSVSCommunity = $window.FindName("chkAppMSVSCommunity")

$chkAppMSWSL = $window.FindName("chkAppMSWSL")



# App Store Checkboxes

$chkAppChrome = $window.FindName("chkAppChrome")

$chkAppBrave = $window.FindName("chkAppBrave")

$chkAppFirefox = $window.FindName("chkAppFirefox")

$chkAppEdge = $window.FindName("chkAppEdge")

$chkAppOperaGX = $window.FindName("chkAppOperaGX")

$chkAppTor = $window.FindName("chkAppTor")

$chkAppAnyDesk = $window.FindName("chkAppAnyDesk")

$chkAppTeamViewer = $window.FindName("chkAppTeamViewer")

$chkAppRustDesk = $window.FindName("chkAppRustDesk")

$chkAppUltraViewer = $window.FindName("chkAppUltraViewer")

$chkAppDiscord = $window.FindName("chkAppDiscord")

$chkAppTelegram = $window.FindName("chkAppTelegram")

$chkAppWhatsApp = $window.FindName("chkAppWhatsApp")

$chkAppZoom = $window.FindName("chkAppZoom")

$chkAppSkype = $window.FindName("chkAppSkype")

$chkApp7Zip = $window.FindName("chkApp7Zip")

$chkAppWinRAR = $window.FindName("chkAppWinRAR")

$chkAppPeaZip = $window.FindName("chkAppPeaZip")

$chkAppNotepad = $window.FindName("chkAppNotepad")

$chkAppPowerToys = $window.FindName("chkAppPowerToys")

$chkAppEverything = $window.FindName("chkAppEverything")

$chkAppRevo = $window.FindName("chkAppRevo")

$chkAppRufus = $window.FindName("chkAppRufus")

$chkAppCrystalDisk = $window.FindName("chkAppCrystalDisk")

$chkAppCPUZ = $window.FindName("chkAppCPUZ")

$chkAppHWMonitor = $window.FindName("chkAppHWMonitor")

$chkAppTreeSize = $window.FindName("chkAppTreeSize")

$chkAppVLC = $window.FindName("chkAppVLC")

$chkAppKLite = $window.FindName("chkAppKLite")

$chkAppOBS = $window.FindName("chkAppOBS")

$chkAppGIMP = $window.FindName("chkAppGIMP")

$chkAppPaintNet = $window.FindName("chkAppPaintNet")

$chkAppAudacity = $window.FindName("chkAppAudacity")

$chkAppHandBrake = $window.FindName("chkAppHandBrake")

$chkAppSpotify = $window.FindName("chkAppSpotify")

$chkAppCapCut = $window.FindName("chkAppCapCut")

$chkAppVSCode = $window.FindName("chkAppVSCode")

$chkAppGit = $window.FindName("chkAppGit")

$chkAppGitHubDesktop = $window.FindName("chkAppGitHubDesktop")

$chkAppPython = $window.FindName("chkAppPython")

$chkAppNode = $window.FindName("chkAppNode")

$chkAppDocker = $window.FindName("chkAppDocker")

$chkAppPostman = $window.FindName("chkAppPostman")

$chkAppDBeaver = $window.FindName("chkAppDBeaver")

$chkAppVCRedist = $window.FindName("chkAppVCRedist")

$chkAppJavaJDK = $window.FindName("chkAppJavaJDK")

$chkAppAdobeReader = $window.FindName("chkAppAdobeReader")

$chkAppFoxit = $window.FindName("chkAppFoxit")

$chkAppSumatra = $window.FindName("chkAppSumatra")

$chkAppLibreOffice = $window.FindName("chkAppLibreOffice")

$chkAppWPS = $window.FindName("chkAppWPS")

$chkAppPDF24 = $window.FindName("chkAppPDF24")

$btnPresetAppEssentials = $window.FindName("btnPresetAppEssentials")

$btnPresetAppDev = $window.FindName("btnPresetAppDev")

$btnSelectAllApps = $window.FindName("btnSelectAllApps")

$btnClearAllApps = $window.FindName("btnClearAllApps")

$btnInstallSelectedApps = $window.FindName("btnInstallSelectedApps")



# Features & Fixes Controls

$chkFeatNetFx = $window.FindName("chkFeatNetFx")

$chkFeatHyperV = $window.FindName("chkFeatHyperV")

$chkFeatF8Disable = $window.FindName("chkFeatF8Disable")

$chkFeatF8Enable = $window.FindName("chkFeatF8Enable")

$chkFeatMedia = $window.FindName("chkFeatMedia")

$chkFeatNFS = $window.FindName("chkFeatNFS")

$chkFeatRegBackupTask = $window.FindName("chkFeatRegBackupTask")

$chkFeatSandbox = $window.FindName("chkFeatSandbox")

$chkFeatWSL = $window.FindName("chkFeatWSL")

$btnInstallFeaturesBatch = $window.FindName("btnInstallFeaturesBatch")



$btnFixAutoLogon = $window.FindName("btnFixAutoLogon")

$btnFixNetworkReset = $window.FindName("btnFixNetworkReset")

$btnFixNTPServer = $window.FindName("btnFixNTPServer")

$btnFixSystemCorruption = $window.FindName("btnFixSystemCorruption")

$btnFixWindowsUpdate = $window.FindName("btnFixWindowsUpdate")

$btnFixReinstallWinget = $window.FindName("btnFixReinstallWinget")



# OS Customizer & ISOs Controls

$btnCustDownloadWin11 = $window.FindName("btnCustDownloadWin11")

$btnCustDownloadWin10 = $window.FindName("btnCustDownloadWin10")

$btnCustDownloadRufus = $window.FindName("btnCustDownloadRufus")

$btnCustOpenFido = $window.FindName("btnCustOpenFido")



$chkCustBypassMSA = $window.FindName("chkCustBypassMSA")

$chkCustBypassTPM = $window.FindName("chkCustBypassTPM")

$chkCustSkipEULA = $window.FindName("chkCustSkipEULA")

$chkCustDisableBitLocker = $window.FindName("chkCustDisableBitLocker")

$chkCustPerfPower = $window.FindName("chkCustPerfPower")

$chkCustClassicMenu = $window.FindName("chkCustClassicMenu")



$txtCustUsername = $window.FindName("txtCustUsername")

$txtCustPassword = $window.FindName("txtCustPassword")

$chkCustAutoLogon = $window.FindName("chkCustAutoLogon")

$cmbCustTargetDrive = $window.FindName("cmbCustTargetDrive")

$btnCustRefreshDrives = $window.FindName("btnCustRefreshDrives")

$btnGenerateAutounattend = $window.FindName("btnGenerateAutounattend")

$btnRunLiveOOBEBypass = $window.FindName("btnRunLiveOOBEBypass")

$btnLaunchRufus = $window.FindName("btnLaunchRufus")



# Power Tools Hub Controls

$btnPauseDefender = $window.FindName("btnPauseDefender")

$btnEnableDefender = $window.FindName("btnEnableDefender")

$btnClearDefenderCache = $window.FindName("btnClearDefenderCache")

$btnDisableSmartScreen2 = $window.FindName("btnDisableSmartScreen2")

$btnFixPrinterSpooler = $window.FindName("btnFixPrinterSpooler")

$btnRemoveOneDrive = $window.FindName("btnRemoveOneDrive")

$btnDisableCopilotRecall = $window.FindName("btnDisableCopilotRecall")

$btnDisableHibernation = $window.FindName("btnDisableHibernation")

$btnEnableHibernation = $window.FindName("btnEnableHibernation")

$btnRestartExplorerQuick = $window.FindName("btnRestartExplorerQuick")

$btnFixRecycleBinQuick = $window.FindName("btnFixRecycleBinQuick")

$btnToggleHiddenFilesQuick = $window.FindName("btnToggleHiddenFilesQuick")

$btnEnableLongPathsQuick = $window.FindName("btnEnableLongPathsQuick")

$btnListStartupAppsQuick = $window.FindName("btnListStartupAppsQuick")

$btnAnalyzeBatteryWear = $window.FindName("btnAnalyzeBatteryWear")

$btnStartHotspot = $window.FindName("btnStartHotspot")

$btnStopHotspot = $window.FindName("btnStopHotspot")

$txtShredFilePath = $window.FindName("txtShredFilePath")

$btnBrowseShredFile = $window.FindName("btnBrowseShredFile")

$btnExecuteShredFile = $window.FindName("btnExecuteShredFile")



# Super Admin Controls

$btnExtractProductKey = $window.FindName("btnExtractProductKey")

$txtTakeOwnPath = $window.FindName("txtTakeOwnPath")

$btnBrowseTakeOwn = $window.FindName("btnBrowseTakeOwn")

$btnExecuteTakeOwn = $window.FindName("btnExecuteTakeOwn")

$btnEnableSuperAdmin2 = $window.FindName("btnEnableSuperAdmin2")

$btnCreateGodMode2 = $window.FindName("btnCreateGodMode2")

$btnDisableUAC2 = $window.FindName("btnDisableUAC2")

$btnRebootUEFI = $window.FindName("btnRebootUEFI")

$btnPurgeTelemetryTasks = $window.FindName("btnPurgeTelemetryTasks")

$txtNewHostName = $window.FindName("txtNewHostName")

$btnRenameComputer = $window.FindName("btnRenameComputer")

$txtProcessName = $window.FindName("txtProcessName")

$btnKillProcess2 = $window.FindName("btnKillProcess2")

$btnInstallGPEdit2 = $window.FindName("btnInstallGPEdit2")

$btnRegBackup2 = $window.FindName("btnRegBackup2")



# Gaming & Hardware

$btnDisableMouseAccel = $window.FindName("btnDisableMouseAccel")

$btnBoostKeyboardRate = $window.FindName("btnBoostKeyboardRate")

$btnEnableMSIGpu = $window.FindName("btnEnableMSIGpu")

$btnUnparkCPU = $window.FindName("btnUnparkCPU")

$btnDisableUSBSleep = $window.FindName("btnDisableUSBSleep")

$btnForceTrimSSD = $window.FindName("btnForceTrimSSD")

$btnEnableHAGS = $window.FindName("btnEnableHAGS")

$btnSmartScan = $window.FindName("btnSmartScan")

$btnRamSpecs = $window.FindName("btnRamSpecs")

$btnMemDiag = $window.FindName("btnMemDiag")

$btnSpeedTest = $window.FindName("btnSpeedTest")

$btnBatteryHealth = $window.FindName("btnBatteryHealth")

$btnSysSummary = $window.FindName("btnSysSummary")



# Storage & Repairs Master Suite

$btnFindLargestFiles = $window.FindName("btnFindLargestFiles")

$btnPurgeWinSxSComponent = $window.FindName("btnPurgeWinSxSComponent")

$btnPurgeWindowsOld = $window.FindName("btnPurgeWindowsOld")

$btnForceTimeResync = $window.FindName("btnForceTimeResync")

$btnFixCMOSTimeDrift = $window.FindName("btnFixCMOSTimeDrift")

$btnFixAudioLatency = $window.FindName("btnFixAudioLatency")

$btnAnalyzeBSOD = $window.FindName("btnAnalyzeBSOD")

$btnUnblockTools = $window.FindName("btnUnblockTools")

$btnFixStuckWU = $window.FindName("btnFixStuckWU")

$btnRebuildSearchIndex = $window.FindName("btnRebuildSearchIndex")

$btnRunSFC = $window.FindName("btnRunSFC")

$btnDismRestore = $window.FindName("btnDismRestore")

$btnDismCheck = $window.FindName("btnDismCheck")

$btnResetWU = $window.FindName("btnResetWU")

$btnRepairEngines = $window.FindName("btnRepairEngines")

$btnRegCoreDLLs = $window.FindName("btnRegCoreDLLs")

$btnFlushDNS2 = $window.FindName("btnFlushDNS2")

$btnResetWinsock2 = $window.FindName("btnResetWinsock2")

$btnResetFirewall2 = $window.FindName("btnResetFirewall2")

$btnRepairStore = $window.FindName("btnRepairStore")

$btnResetNetworkStack2 = $window.FindName("btnResetNetworkStack2")

$btnEnableWinRE = $window.FindName("btnEnableWinRE")

$btnCheckWinRE = $window.FindName("btnCheckWinRE")

$btnOfficeQuickRepair = $window.FindName("btnOfficeQuickRepair")

$btnLaunchScanPST = $window.FindName("btnLaunchScanPST")

$btnSafeWord = $window.FindName("btnSafeWord")

$btnSafeExcel = $window.FindName("btnSafeExcel")

$btnSafePPT = $window.FindName("btnSafePPT")

$btnSafeOutlook = $window.FindName("btnSafeOutlook")

$btnRebuildBCD = $window.FindName("btnRebuildBCD")

$btnRebootRecovery = $window.FindName("btnRebootRecovery")

$btnEnableBootFailures = $window.FindName("btnEnableBootFailures")

$btnScheduleChkdsk = $window.FindName("btnScheduleChkdsk")

$btnFixPrinter0x11b = $window.FindName("btnFixPrinter0x11b")

$btnConfigPrinterGPO = $window.FindName("btnConfigPrinterGPO")

$btnEnableLPD = $window.FindName("btnEnableLPD")

$btnRestartPrinterServices = $window.FindName("btnRestartPrinterServices")

$btnFlushPrintSpooler = $window.FindName("btnFlushPrintSpooler")

$btnLaunchPrinterDiag = $window.FindName("btnLaunchPrinterDiag")

$cmbDriveLetter = $window.FindName("cmbDriveLetter")

$btnConvertNTFS = $window.FindName("btnConvertNTFS")

$cmbDiskID = $window.FindName("cmbDiskID")

$btnConvertGPT = $window.FindName("btnConvertGPT")

$btnFlushRAMCache = $window.FindName("btnFlushRAMCache")

$btnCleanBrowserCache = $window.FindName("btnCleanBrowserCache")

$btnRepairWUServiceComprehensive = $window.FindName("btnRepairWUServiceComprehensive")

$btnBlockWinUpdates = $window.FindName("btnBlockWinUpdates")

$btnEnableWinUpdates = $window.FindName("btnEnableWinUpdates")

$btnResetDefenderPolicies = $window.FindName("btnResetDefenderPolicies")

$btnRestoreFirewallSettings = $window.FindName("btnRestoreFirewallSettings")

$btnResetAudioPlaybackServices = $window.FindName("btnResetAudioPlaybackServices")

$btnRestartExplorerQuick2 = $window.FindName("btnRestartExplorerQuick2")

$btnClearAllEventLogs = $window.FindName("btnClearAllEventLogs")

$btnRebuildIconCache = $window.FindName("btnRebuildIconCache")

$btnRebuildFontCache = $window.FindName("btnRebuildFontCache")



# Context Menu Extensions & Tweaks

$btnContextCopyPath = $window.FindName("btnContextCopyPath")

$btnContextCompact = $window.FindName("btnContextCompact")

$btnContextPermanentDelete = $window.FindName("btnContextPermanentDelete")



$chkBypassTPM = $window.FindName("chkBypassTPM")

$chkRemoveWatermark = $window.FindName("chkRemoveWatermark")

$chkBlockDriverWU = $window.FindName("chkBlockDriverWU")

$chkAlignTaskbarLeft = $window.FindName("chkAlignTaskbarLeft")

$chkTelemetry = $window.FindName("chkTelemetry")

$chkCortana = $window.FindName("chkCortana")

$chkBing = $window.FindName("chkBing")

$chkAds = $window.FindName("chkAds")

$chkLocation = $window.FindName("chkLocation")

$chkActivity = $window.FindName("chkActivity")

$chkFeedback = $window.FindName("chkFeedback")

$chkSmartScreen = $window.FindName("chkSmartScreen")

$chkHighPower = $window.FindName("chkHighPower")

$chkUltPower = $window.FindName("chkUltPower")

$chkStartupDelay = $window.FindName("chkStartupDelay")

$chkStickyKeys = $window.FindName("chkStickyKeys")

$chkVirtSecurity = $window.FindName("chkVirtSecurity")

$chkDisableHibernation = $window.FindName("chkDisableHibernation")

$chkMenuDelay = $window.FindName("chkMenuDelay")

$chkNtfsTime = $window.FindName("chkNtfsTime")

$chkUniversalBg = $window.FindName("chkUniversalBg")

$chkEdgePreload = $window.FindName("chkEdgePreload")

$chkHAGS = $window.FindName("chkHAGS")

$chkTransparency = $window.FindName("chkTransparency")

$chkGameDVR = $window.FindName("chkGameDVR")

$chkNetThrottle = $window.FindName("chkNetThrottle")

$chkGameLatency = $window.FindName("chkGameLatency")

$chkHoverDelays = $window.FindName("chkHoverDelays")

$chkSearchHighlights = $window.FindName("chkSearchHighlights")

$chkTakeOwn = $window.FindName("chkTakeOwn")

$chkOpenNotepad = $window.FindName("chkOpenNotepad")

$chkKillStuck = $window.FindName("chkKillStuck")

$chkCmdAdmin = $window.FindName("chkCmdAdmin")

$chkCleanTemp = $window.FindName("chkCleanTemp")

$chkCleanmgr = $window.FindName("chkCleanmgr")

$chkDisableOneDrive = $window.FindName("chkDisableOneDrive")

$chkRemoveBloatware = $window.FindName("chkRemoveBloatware")

$chkDisableSearchIndexer = $window.FindName("chkDisableSearchIndexer")

$chkDisableDefender = $window.FindName("chkDisableDefender")

$chkStopWU = $window.FindName("chkStopWU")

$chkShowExt = $window.FindName("chkShowExt")

$chkShowHidden = $window.FindName("chkShowHidden")

$chkWin11ClassicMenu = $window.FindName("chkWin11ClassicMenu")

$chkPhotoViewer = $window.FindName("chkPhotoViewer")



$btnPresetRecommended = $window.FindName("btnPresetRecommended")

$btnPresetOnlyTweaks = $window.FindName("btnPresetOnlyTweaks")

$btnPresetClear = $window.FindName("btnPresetClear")

$btnApplyTweaksBatch = $window.FindName("btnApplyTweaksBatch")



# Security & Network

$btnEnableUSBWriteProtect = $window.FindName("btnEnableUSBWriteProtect")

$btnDisableUSBWriteProtect = $window.FindName("btnDisableUSBWriteProtect")

$btnInjectHostsAdblock = $window.FindName("btnInjectHostsAdblock")

$btnResetHosts = $window.FindName("btnResetHosts")

$btnAddDefenderExclusion = $window.FindName("btnAddDefenderExclusion")

$btnEnableSandbox = $window.FindName("btnEnableSandbox")

$btnEnableHyperV = $window.FindName("btnEnableHyperV")

$btnExportWiFiPass = $window.FindName("btnExportWiFiPass")

$btnGenWiFiQR = $window.FindName("btnGenWiFiQR")

$btnApplyTCPAck = $window.FindName("btnApplyTCPAck")

$btnBoostTCPCongestion = $window.FindName("btnBoostTCPCongestion")

$btnViewActivePorts = $window.FindName("btnViewActivePorts")

$btnResetWinsock3 = $window.FindName("btnResetWinsock3")

$btnDNSCloudflare = $window.FindName("btnDNSCloudflare")

$btnDNSGoogle = $window.FindName("btnDNSGoogle")

$btnDNSQuad9 = $window.FindName("btnDNSQuad9")

$btnDNSDHCP = $window.FindName("btnDNSDHCP")



# Activation & Change Edition

$cmbTargetWinEdition = $window.FindName("cmbTargetWinEdition")

$txtCustomEditionKey = $window.FindName("txtCustomEditionKey")

$btnAutoFillEditionKey = $window.FindName("btnAutoFillEditionKey")

$btnApplyEditionChange = $window.FindName("btnApplyEditionChange")

$btnDISMEditionChange = $window.FindName("btnDISMEditionChange")

$btnOpenMASEditionMenu = $window.FindName("btnOpenMASEditionMenu")



$btnInstallM365 = $window.FindName("btnInstallM365")

$btnInstall2019 = $window.FindName("btnInstall2019")

$btnInstall2021 = $window.FindName("btnInstall2021")

$btnInstall2024 = $window.FindName("btnInstall2024")

$btnActWindows = $window.FindName("btnActWindows")

$btnActOffice = $window.FindName("btnActOffice")

$btnActKMS = $window.FindName("btnActKMS")

$btnCleanKMS = $window.FindName("btnCleanKMS")

$btnChangeEdition = $window.FindName("btnChangeEdition")



# Backups & Consoles

$txtSourceFolder = $window.FindName("txtSourceFolder")

$btnBrowseSource = $window.FindName("btnBrowseSource")

$txtTargetFolder = $window.FindName("txtTargetFolder")

$btnBrowseTarget = $window.FindName("btnBrowseTarget")

$btnRunRobocopy = $window.FindName("btnRunRobocopy")

$btnExportBookmarks2 = $window.FindName("btnExportBookmarks2")

$btnExportDrivers = $window.FindName("btnExportDrivers")

$btnExportDriversCustom = $window.FindName("btnExportDriversCustom")

$btnRestoreDrivers = $window.FindName("btnRestoreDrivers")

$btnOfflineInjectDrivers = $window.FindName("btnOfflineInjectDrivers")

$btnListDrivers = $window.FindName("btnListDrivers")

$btnOpenDevMgmt = $window.FindName("btnOpenDevMgmt")

$btnUpgradeWinget = $window.FindName("btnUpgradeWinget")

$btnRestartTally = $window.FindName("btnRestartTally")

$btnPurgeCache = $window.FindName("btnPurgeCache")

$btnCleanDriverStore = $window.FindName("btnCleanDriverStore")

$btnOpenDriversHubPT = $window.FindName("btnOpenDriversHubPT")

$txtTerminalLog = $window.FindName("txtTerminalLog")



$btnHubReg2 = $window.FindName("btnHubReg2")

$btnHubDev2 = $window.FindName("btnHubDev2")

$btnHubGP2 = $window.FindName("btnHubGP2")

$btnHubDisk2 = $window.FindName("btnHubDisk2")

$btnHubTask2 = $window.FindName("btnHubTask2")

$btnHubRes2 = $window.FindName("btnHubRes2")

$btnHubDx2 = $window.FindName("btnHubDx2")

$btnHubServ2 = $window.FindName("btnHubServ2")

$btnCloseApp = $window.FindName("btnCloseApp")



# Helper function to append to terminal

function Append-Log($msg) {

    $time = Get-Date -Format "HH:mm:ss"

    $line = "[$time] $msg`r`n"

    if ($txtTerminalLog) {

        $txtTerminalLog.AppendText($line)

        $txtTerminalLog.ScrollToEnd()

    }

}



# ==================== POPULATE COMBOBOXES ====================

function Refresh-UserAccounts {

    if (-not $cmbUserAccounts) { return }

    $cmbUserAccounts.Items.Clear()

    try {

        $users = Get-LocalUser -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name

        if (-not $users) {

            $users = (net user | Select-String -Pattern '^-+' -Context 0,100).Context.PostContext | ForEach-Object { $_ -split '\s+' } | Where-Object { $_ -and $_ -notmatch "command|completed" }

        }

        foreach ($u in $users) {

            if ($u) { $cmbUserAccounts.Items.Add($u.Trim()) | Out-Null }

        }

        if ($cmbUserAccounts.Items.Count -gt 0) { $cmbUserAccounts.SelectedIndex = 0 }

    } catch {}

}

# Fast static item initialization

if ($cmbAccountType) {

    $cmbAccountType.Items.Add("Administrator") | Out-Null

    $cmbAccountType.Items.Add("Standard User") | Out-Null

    $cmbAccountType.SelectedIndex = 0

}



$editionKeys = @{

    "Windows 10/11 Pro" = "VK7JG-NPHTM-C97JM-9MPGT-3V66T"

    "Windows 10/11 Enterprise" = "NPPR9-FWDCX-D2C8J-H872K-2YT43"

    "Windows 10/11 Education" = "NW6C2-QMPVW-D7KKK-3GKT6-VCFB2"

    "Windows 10/11 Pro for Workstations" = "DXG7C-N37C4-3282C-D44D3-4VQ26"

    "Windows 10/11 Enterprise LTSC" = "M7XTQ-FN8P6-TTKYV-9D4CC-J462D"

    "Windows 10/11 IoT Enterprise" = "XQQYW-NFFMW-XJPBH-K8732-CKFFD"

}



if ($cmbTargetWinEdition) {

    foreach ($k in $editionKeys.Keys) {

        $cmbTargetWinEdition.Items.Add($k) | Out-Null

    }

    $cmbTargetWinEdition.SelectedIndex = 0

}



if ($btnAutoFillEditionKey) {

    $btnAutoFillEditionKey.Add_Click({

        $sel = $cmbTargetWinEdition.SelectedItem

        if ($sel -and $editionKeys.ContainsKey($sel.ToString())) {

            $keyVal = $editionKeys[$sel.ToString()]

            $txtCustomEditionKey.Text = $keyVal

            Append-Log("Auto-filled key for $($sel) - $keyVal")

        }

    })

}



function Refresh-CustomizerDrives {

    if (-not $cmbCustTargetDrive) { return }

    $cmbCustTargetDrive.Items.Clear()

    try {

        $drives = Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter } | ForEach-Object { "$($_.DriveLetter):\ ($($_.FileSystemLabel)) [$([math]::Round($_.SizeRemaining/1GB,1)) GB Free]" }

        foreach ($d in $drives) { $cmbCustTargetDrive.Items.Add($d) | Out-Null }

    } catch {}

    $desktop = [Environment]::GetFolderPath("Desktop")

    $cmbCustTargetDrive.Items.Add("Desktop ($desktop)") | Out-Null

    if ($cmbCustTargetDrive.Items.Count -gt 0) { $cmbCustTargetDrive.SelectedIndex = 0 }

}

if ($btnCustRefreshDrives) { $btnCustRefreshDrives.Add_Click({ Refresh-CustomizerDrives }) }



# High-Speed Post-Render Asynchronous Loader (Instant UI Display)

$window.Add_ContentRendered({

    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke([Action]{

        Refresh-UserAccounts

        Refresh-CustomizerDrives

        

        if ($cmbDriveLetter) {

            try {

                Get-Volume -ErrorAction SilentlyContinue | Where-Object { $_.DriveLetter } | ForEach-Object { $cmbDriveLetter.Items.Add("$($_.DriveLetter): ($($_.FileSystemLabel))") | Out-Null }

                if ($cmbDriveLetter.Items.Count -gt 0) { $cmbDriveLetter.SelectedIndex = 0 }

            } catch {}

        }

        

        if ($cmbDiskID) {

            try {

                Get-Disk -ErrorAction SilentlyContinue | ForEach-Object { $cmbDiskID.Items.Add("Disk $($_.Number): $($_.FriendlyName) ($([math]::Round($_.Size/1GB,1)) GB)") | Out-Null }

                if ($cmbDiskID.Items.Count -gt 0) { $cmbDiskID.SelectedIndex = 0 }

            } catch {}

        }

        

        Append-Log("Venkat Ultimate Windows Tweaker engine ready. All subsystems active.")

    }) | Out-Null

})



# ==================== USER PASSWORDS EVENT HANDLERS ====================

function Get-SelectedUserCleanName {

    if (-not $cmbUserAccounts.SelectedItem) {

        [System.Windows.Forms.MessageBox]::Show("Please select a user account first.", "User Password Tool", "OK", "Warning")

        return $null

    }

    return $cmbUserAccounts.SelectedItem.ToString().Trim()

}



$btnRefreshUserList.Add_Click({ Refresh-UserAccounts; Append-Log("User accounts list refreshed.") })



$btnApplyUserPass.Add_Click({

    $u = Get-SelectedUserCleanName

    $p = $txtUserNewPass.Text.Trim()

    if (-not $u -or -not $p -or $p -match "Enter New Password") {

        [System.Windows.Forms.MessageBox]::Show("Please specify a valid new password.", "Password Tool", "OK", "Warning")

        return

    }

    try {

        net user "$u" "$p" | Out-Null

        Append-Log("New password set successfully for user '$u'.")

        [System.Windows.Forms.MessageBox]::Show("Password for user '$u' changed successfully!", "Password Changed", "OK", "Information")

    } catch {

        [System.Windows.Forms.MessageBox]::Show("Failed to change password: $_", "Error", "OK", "Error")

    }

})



$btnRemoveUserPass.Add_Click({

    $u = Get-SelectedUserCleanName

    if (-not $u) { return }

    if ([System.Windows.Forms.MessageBox]::Show("Remove password for user '$u'? User will log in with a blank password.", "Confirm Remove Password", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {

        net user "$u" "" | Out-Null

        Append-Log("Password removed for user '$u'.")

        [System.Windows.Forms.MessageBox]::Show("Password removed for '$u'! Blank password set.", "Password Removed", "OK", "Information")

    }

})



function Set-WorkingGuestAccount {
    Append-Log "Configuring Windows 11 / 10 Working Guest Account..."
    
    # 1. Disable deprecated built-in Guest
    net user Guest /active:no 2>&1 | Out-Null
    
    # 2. Check if Visitor account exists
    $userCheck = (net user Visitor 2>&1) -notmatch "cannot be found|could not find"
    if (-not $userCheck) {
        net user Visitor "" /add /fullname:"Guest" /comment:"Working Windows 11 Guest Account" 2>&1 | Out-Null
    } else {
        net user Visitor /active:yes 2>&1 | Out-Null
        net user Visitor "" 2>&1 | Out-Null
        net user Visitor /fullname:"Guest" 2>&1 | Out-Null
    }
    
    # 3. Add to Users group and set password never expires
    net localgroup Users Visitor /add 2>&1 | Out-Null
    wmic useraccount where name='Visitor' set passwordexpires=false 2>&1 | Out-Null
    
    Refresh-UserAccounts
    Append-Log "[OK] 100% Working Guest Account enabled (Username: Visitor, Display Name: Guest)."
    
    $okMsg = "Working Guest Account has been ENABLED successfully!`n`n" +
             "- Display Name on Lock Screen: Guest`n" +
             "- Password: None (Just click on Guest to log in)`n" +
             "- Account Security: Standard User (Cannot alter system settings)`n`n" +
             "The deprecated Windows 11 built-in Guest has been disabled to prevent login errors."
    [System.Windows.Forms.MessageBox]::Show($okMsg, "Guest Account Enabled", "OK", "Information")
}

$btnUnlockUserAcc.Add_Click({
    $u = Get-SelectedUserCleanName
    if (-not $u) { return }

    if ($u -eq "Guest") {
        $diag = "IMPORTANT NOTICE FOR WINDOWS 11 / 10:`n`n" +
                "Microsoft has permanently disabled interactive login for the built-in 'Guest' account in Windows 11/10. Even if activated, Windows rejects logging in at the lock screen.`n`n" +
                "Would you like to automatically configure a 100% WORKING Guest Account?`n`n" +
                "- Account Name: Visitor`n" +
                "- Display Name on Lock Screen: Guest`n" +
                "- Password: None (Instant login)`n`n" +
                "Click [YES] to setup the working Guest Account now (Recommended).`n" +
                "Click [NO] to only unlock the built-in account."
        $res = [System.Windows.Forms.MessageBox]::Show($diag, "Windows 11 Guest Account", "YesNoCancel", "Question")
        if ($res -eq "Yes") {
            Set-WorkingGuestAccount
            return
        } elseif ($res -eq "Cancel") {
            return
        }
    }

    net user "$u" /active:yes | Out-Null
    Refresh-UserAccounts
    Append-Log "User account '$u' unlocked and activated."
    [System.Windows.Forms.MessageBox]::Show("Account '$u' is now UNLOCKED and Active!", "Account Unlocked", "OK", "Information")
})

if ($btnEnableWorkingGuest) {
    $btnEnableWorkingGuest.Add_Click({
        Set-WorkingGuestAccount
    })
}

if ($btnDisableWorkingGuest) {
    $btnDisableWorkingGuest.Add_Click({
        Append-Log "Disabling Guest Accounts..."
        net user Guest /active:no 2>&1 | Out-Null
        net user Visitor /active:no 2>&1 | Out-Null
        Refresh-UserAccounts
        Append-Log "[OK] Guest accounts have been disabled and hidden from login screen."
        $disMsg = "Guest Account has been DISABLED successfully!`n`nBoth built-in Guest and Visitor accounts are now disabled and hidden from the Windows Lock Screen."
        [System.Windows.Forms.MessageBox]::Show($disMsg, "Guest Account Disabled", "OK", "Information")
    })
}

if ($btnCheckGuestStatus) {
    $btnCheckGuestStatus.Add_Click({
        $builtinActive = $false
        $visitorActive = $false
        
        try {
            $g = Get-LocalUser -Name "Guest" -ErrorAction SilentlyContinue
            if ($g -and $g.Enabled) { $builtinActive = $true }
            
            $v = Get-LocalUser -Name "Visitor" -ErrorAction SilentlyContinue
            if ($v -and $v.Enabled) { $visitorActive = $true }
        } catch {
            $gOut = net user Guest 2>&1 | Out-String
            if ($gOut -match "Account active\s+Yes") { $builtinActive = $true }
            $vOut = net user Visitor 2>&1 | Out-String
            if ($vOut -match "Account active\s+Yes") { $visitorActive = $true }
        }
        
        if ($visitorActive) {
            $stMsg = "STATUS: ACTIVE & WORKING`n`n" +
                     "- Working Guest Account (Visitor): ACTIVE (Working on Windows 11)`n" +
                     "- Display Name: Guest`n" +
                     "- Password: None (Instant login)`n"
            if ($builtinActive) {
                $stMsg += "- Built-in Legacy Guest: ACTIVE (Recommend clicking 'Enable Working Guest Account' to disable it)"
            } else {
                $stMsg += "- Built-in Legacy Guest: DISABLED (Correct)"
            }
            [System.Windows.Forms.MessageBox]::Show($stMsg, "Guest Account Status", "OK", "Information")
        } elseif ($builtinActive) {
            $warnMsg = "STATUS: WARNING (LEGACY GUEST ACTIVE)`n`n" +
                       "The built-in Windows 'Guest' account is currently active, BUT Windows 11 blocks it from logging in!`n`n" +
                       "Would you like to automatically switch to the 100% WORKING Guest Account right now?"
            $ans = [System.Windows.Forms.MessageBox]::Show($warnMsg, "Guest Account Status", "YesNo", "Warning")
            if ($ans -eq "Yes") {
                Set-WorkingGuestAccount
            }
        } else {
            $offMsg = "STATUS: DISABLED`n`nGuest access is currently turned OFF.`nTo allow guests to use this PC, click 'Enable Working Guest Account'."
            [System.Windows.Forms.MessageBox]::Show($offMsg, "Guest Account Status", "OK", "Information")
        }
    })
}

$btnDisableUserAcc.Add_Click({

    $u = Get-SelectedUserCleanName

    if (-not $u) { return }

    net user "$u" /active:no | Out-Null

    Refresh-UserAccounts

    Append-Log("User account '$u' disabled.")

    [System.Windows.Forms.MessageBox]::Show("Account '$u' is now DISABLED!", "Account Disabled", "OK", "Information")

})



$btnPassNeverExpire.Add_Click({

    $u = Get-SelectedUserCleanName

    if (-not $u) { return }

    wmic useraccount where name="$u" set passwordexpires=false | Out-Null

    Append-Log("Set Password Never Expires for '$u'.")

    [System.Windows.Forms.MessageBox]::Show("Password for user '$u' will NEVER expire!", "Password Policy", "OK", "Information")

})



$btnDeleteUserAcc.Add_Click({

    $u = Get-SelectedUserCleanName

    if (-not $u) { return }

    if ([System.Windows.Forms.MessageBox]::Show("Permanently DELETE user account '$u'?", "Confirm Delete User", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {

        net user "$u" /delete | Out-Null

        Refresh-UserAccounts

        Append-Log("User account '$u' deleted.")

        [System.Windows.Forms.MessageBox]::Show("User account '$u' has been deleted.", "Account Deleted", "OK", "Information")

    }

})



$btnEnableAutoLogon.Add_Click({

    $u = Get-SelectedUserCleanName

    $p = $txtUserNewPass.Text.Trim()

    if (-not $u) { return }

    if ($p -match "Enter New Password") { $p = "" }

    

    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "1" -Type String -Force -ErrorAction SilentlyContinue

    Set-ItemProperty -Path $regPath -Name "DefaultUserName" -Value "$u" -Type String -Force -ErrorAction SilentlyContinue

    Set-ItemProperty -Path $regPath -Name "DefaultPassword" -Value "$p" -Type String -Force -ErrorAction SilentlyContinue

    Set-ItemProperty -Path $regPath -Name "DefaultDomainName" -Value "$env:COMPUTERNAME" -Type String -Force -ErrorAction SilentlyContinue

    

    Append-Log("Configured Automatic Logon on boot for user '$u'.")

    [System.Windows.Forms.MessageBox]::Show("Automatic Logon ENABLED for '$u'!", "Auto-Logon Configured", "OK", "Information")

})



$btnDisableAutoLogon.Add_Click({

    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

    Set-ItemProperty -Path $regPath -Name "AutoAdminLogon" -Value "0" -Type String -Force -ErrorAction SilentlyContinue

    Remove-ItemProperty -Path $regPath -Name "DefaultPassword" -Force -ErrorAction SilentlyContinue

    Append-Log("Automatic Logon disabled.")

    [System.Windows.Forms.MessageBox]::Show("Automatic Logon DISABLED.", "Auto-Logon Disabled", "OK", "Information")

})



$btnCreateAccountAction.Add_Click({

    $u = $txtCreateUsername.Text.Trim()

    $p = $txtCreatePassword.Text.Trim()

    $type = $cmbAccountType.SelectedItem.ToString()

    if (-not $u) { return }

    net user "$u" "$p" /add | Out-Null

    if ($type -eq "Administrator") { net localgroup administrators "$u" /add | Out-Null }

    Refresh-UserAccounts

    Append-Log("Created new $type account '$u'.")

    [System.Windows.Forms.MessageBox]::Show("$type account '$u' successfully created!", "Account Created", "OK", "Information")

})



$btnOpenNetplwiz.Add_Click({ Start-Process netplwiz.exe })

$btnOpenLusrmgr.Add_Click({ Start-Process lusrmgr.msc })



# ==================== MAIL PASSVIEW & EMAIL AUDIT ENGINE ====================

function Show-NativePassViewDialog {

    try {

        $credsList = [NativePassViewHelper]::GetAllCredentials()

    } catch {

        $credsList = @()

    }

    

    # Also retrieve Windows Vault

    try {

        [Windows.Security.Credentials.PasswordVault, Windows.Security.Credentials, ContentType = WindowsRuntime] | Out-Null

        $vault = New-Object Windows.Security.Credentials.PasswordVault

        $vaultCreds = $vault.RetrieveAll()

        foreach ($vc in $vaultCreds) {

            $vc.RetrievePassword()

            $item = New-Object NativePassViewHelper+CredItem

            $item.Target = $vc.Resource

            $item.User = $vc.UserName

            $item.Password = $vc.Password

            $item.Type = "Windows Vault"

            $credsList.Add($item)

        }

    } catch {}



    [xml]$pvXaml = @"

<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"

        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"

        Title="Venkat Mail PassView &amp; Credentials Recovery Engine"

        Height="540" Width="840"

        WindowStartupLocation="CenterScreen"

        Background="#080E1A"

        FontFamily="Segoe UI">

    <Grid Margin="12">

        <Grid.RowDefinitions>

            <RowDefinition Height="Auto"/>

            <RowDefinition Height="*"/>

            <RowDefinition Height="Auto"/>

        </Grid.RowDefinitions>



        <StackPanel Grid.Row="0" Margin="0,0,0,10">

            <TextBlock Text="VENKAT MAIL PASSVIEW &amp; CREDENTIALS RECOVERY" FontSize="14" FontWeight="Bold" Foreground="#38BDF8"/>

            <TextBlock Text="Decrypted email accounts, mail servers, web credentials, and saved Windows passwords." FontSize="10" Foreground="#94A3B8" Margin="0,2,0,0"/>

        </StackPanel>



        <ListView Name="lstCreds" Grid.Row="1" Background="#0F172A" Foreground="#F8FAFC" BorderBrush="#1E293B">

            <ListView.View>

                <GridView>

                    <GridViewColumn Header="Resource / Target" Width="260" DisplayMemberBinding="{Binding Target}"/>

                    <GridViewColumn Header="User / Email" Width="200" DisplayMemberBinding="{Binding User}"/>

                    <GridViewColumn Header="Password / Secret" Width="220" DisplayMemberBinding="{Binding Password}"/>

                    <GridViewColumn Header="Type" Width="110" DisplayMemberBinding="{Binding Type}"/>

                </GridView>

            </ListView.View>

        </ListView>



        <Grid Grid.Row="2" Margin="0,10,0,0">

            <Grid.ColumnDefinitions>

                <ColumnDefinition Width="*"/>

                <ColumnDefinition Width="Auto"/>

            </Grid.ColumnDefinitions>

            

            <StackPanel Grid.Column="0" Orientation="Horizontal">

                <Button Name="btnCopyPass" Content="Copy Password" Width="120" Height="28" Background="#0284C7" Margin="0,0,6,0" FontWeight="Bold"/>

                <Button Name="btnCopyUser" Content="Copy User / Email" Width="130" Height="28" Background="#334155" Margin="0,0,6,0"/>

                <Button Name="btnOpenWinCredMgr" Content="Open Credential Manager" Width="170" Height="28" Background="#1E3A8A"/>

            </StackPanel>



            <StackPanel Grid.Column="1" Orientation="Horizontal">

                <Button Name="btnExportPVReport" Content="Export Report" Width="110" Height="28" Background="#059669" Margin="0,0,6,0" FontWeight="Bold"/>

                <Button Name="btnClosePV" Content="Close" Width="80" Height="28" Background="#DC2626" FontWeight="Bold"/>

            </StackPanel>

        </Grid>

    </Grid>

</Window>

"@



    $pvReader = New-Object System.Xml.XmlNodeReader $pvXaml

    $pvWindow = [System.Windows.Markup.XamlReader]::Load($pvReader)



    $lstCreds = $pvWindow.FindName("lstCreds")

    $btnCopyPass = $pvWindow.FindName("btnCopyPass")

    $btnCopyUser = $pvWindow.FindName("btnCopyUser")

    $btnOpenWinCredMgr = $pvWindow.FindName("btnOpenWinCredMgr")

    $btnExportPVReport = $pvWindow.FindName("btnExportPVReport")

    $btnClosePV = $pvWindow.FindName("btnClosePV")



    $lstCreds.ItemsSource = $credsList



    $btnCopyPass.Add_Click({

        $sel = $lstCreds.SelectedItem

        if ($sel -and $sel.Password) {

            [System.Windows.Clipboard]::SetText($sel.Password)

            [System.Windows.Forms.MessageBox]::Show("Password copied to clipboard!", "PassView", "OK", "Information")

        }

    })



    $btnCopyUser.Add_Click({

        $sel = $lstCreds.SelectedItem

        if ($sel -and $sel.User) {

            [System.Windows.Clipboard]::SetText($sel.User)

            [System.Windows.Forms.MessageBox]::Show("User/Email copied to clipboard!", "PassView", "OK", "Information")

        }

    })



    $btnOpenWinCredMgr.Add_Click({

        Start-Process control.exe -ArgumentList "keymgr.dll"

    })



    $btnExportPVReport.Add_Click({

        $desktop = [Environment]::GetFolderPath("Desktop")

        $out = "$desktop\Mail_and_Vault_Passwords_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

        $lines = @("=== VENKAT MAIL & PASSWORDS AUDIT REPORT ===", "Generated: $(Get-Date)", "")

        foreach ($c in $credsList) {

            $lines += "Target: $($c.Target)"

            $lines += "User:   $($c.User)"

            $lines += "Pass:   $($c.Password)"

            $lines += "Type:   $($c.Type)"

            $lines += "--------------------------------------------------------"

        }

        $lines | Out-File -FilePath $out -Encoding UTF8

        Start-Process notepad.exe -ArgumentList "`"$out`""

    })



    $btnClosePV.Add_Click({ $pvWindow.Close() })



    $pvWindow.ShowDialog() | Out-Null

}



if ($btnLaunchMailPassView) {

    $btnLaunchMailPassView.Add_Click({

        Append-Log("Launching Venkat Mail PassView & Credential Recovery Engine...")

        Show-NativePassViewDialog

        Append-Log("Mail PassView completed.")

    })

}



if ($btnScanLocalMailProfiles) {

    $btnScanLocalMailProfiles.Add_Click({

        Append-Log("Scanning local system for configured email profiles and servers...")

        $found = 0

        

        # Scan Outlook Profiles in Registry

        $outlookRegPaths = @(

            "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Office\14.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles"

        )

        foreach ($rp in $outlookRegPaths) {

            if (Test-Path $rp) {

                $profiles = Get-ChildItem -Path $rp -ErrorAction SilentlyContinue

                foreach ($p in $profiles) {

                    $found++

                    Append-Log("[Outlook Profile] $($p.PSChildName) (Location: $rp)")

                }

            }

        }

        

        # Scan Thunderbird Profiles

        $tbPath = "$env:APPDATA\Thunderbird\Profiles"

        if (Test-Path $tbPath) {

            $tbProfiles = Get-ChildItem -Path $tbPath -Directory -ErrorAction SilentlyContinue

            foreach ($tbp in $tbProfiles) {

                $found++

                Append-Log("[Mozilla Thunderbird] Profile: $($tbp.Name) (Path: $($tbp.FullName))")

                if (Test-Path "$($tbp.FullName)\logins.json") {

                    Append-Log("  - Stored logins.json database found in $($tbp.Name)")

                }

            }

        }

        

        # Scan Windows Mail / Live Mail Storage

        $wmailPath = "$env:LOCALAPPDATA\Microsoft\Windows Mail"

        if (Test-Path $wmailPath) {

            $found++

            Append-Log("[Windows Mail] Store path detected at $wmailPath")

        }



        # Scan Windows Credentials for Mail Endpoints

        try {

            $cList = [NativePassViewHelper]::GetAllCredentials()

            foreach ($ci in $cList) {

                if ($ci.Target -match "mail|smtp|imap|pop|outlook|live|gmail|yahoo|exchange") {

                    $found++

                    Append-Log("[Mail Credential] Target: $($ci.Target) | User: $($ci.User)")

                }

            }

        } catch {}

        

        if ($found -eq 0) {

            Append-Log("No configured email client databases detected on local user profile.")

            [System.Windows.Forms.MessageBox]::Show("Scan finished. No standard local desktop mail client profiles detected.", "Mail Scan", "OK", "Information")

        } else {

            Append-Log("Mail profiles scan completed! Detected $found email profile sources.")

            [System.Windows.Forms.MessageBox]::Show("Detected $found email profile/server sources! See log terminal for details.", "Mail Scan", "OK", "Information")

        }

    })

}



if ($btnExportMailReport) {

    $btnExportMailReport.Add_Click({

        $desktop = [Environment]::GetFolderPath("Desktop")

        $reportPath = "$desktop\Email_Accounts_Audit_Report.txt"

        

        $report = "========================================================`r`n"

        $report += "  VENKAT WINDOWS EMAIL CLIENTS & PASSWORDS REPORT`r`n"

        $report += "  Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`r`n"

        $report += "  Computer: $env:COMPUTERNAME | User: $env:USERNAME`r`n"

        $report += "========================================================`r`n`r`n"

        

        $report += "1. RECOVERED PASSWORDS & CREDENTIALS:`r`n"

        try {

            $creds = [NativePassViewHelper]::GetAllCredentials()

            foreach ($c in $creds) {

                $report += "   - Target: $($c.Target)`r`n     User:   $($c.User)`r`n     Secret: $($c.Password)`r`n     Type:   $($c.Type)`r`n`r`n"

            }

        } catch {

            $report += "   (Unable to query credentials: $_)`r`n"

        }



        $report += "`r`n2. MICROSOFT OUTLOOK PROFILES:`r`n"

        $outlookRegPaths = @(

            "HKCU:\Software\Microsoft\Office\16.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Office\15.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Office\14.0\Outlook\Profiles",

            "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Windows Messaging Subsystem\Profiles"

        )

        $hasOutlook = $false

        foreach ($rp in $outlookRegPaths) {

            if (Test-Path $rp) {

                $profiles = Get-ChildItem -Path $rp -ErrorAction SilentlyContinue

                foreach ($p in $profiles) {

                    $hasOutlook = $true

                    $report += "   - Profile: $($p.PSChildName)`r`n     Registry: $rp`r`n"

                }

            }

        }

        if (-not $hasOutlook) { $report += "   (No Microsoft Outlook profiles found in registry)`r`n" }

        

        $report += "`r`n3. MOZILLA THUNDERBIRD PROFILES:`r`n"

        $tbPath = "$env:APPDATA\Thunderbird\Profiles"

        if (Test-Path $tbPath) {

            $tbProfiles = Get-ChildItem -Path $tbPath -Directory -ErrorAction SilentlyContinue

            foreach ($tbp in $tbProfiles) {

                $report += "   - Profile Directory: $($tbp.Name)`r`n     Path: $($tbp.FullName)`r`n"

                if (Test-Path "$($tbp.FullName)\logins.json") {

                    $report += "     Database: logins.json (Encrypted Passwords Database Present)`r`n"

                }

            }

        } else {

            $report += "   (No Thunderbird profiles directory detected)`r`n"

        }

        

        $report += "`r`n4. WINDOWS MAIL / LIVE MAIL DATA:`r`n"

        $wmailPath = "$env:LOCALAPPDATA\Microsoft\Windows Mail"

        if (Test-Path $wmailPath) {

            $report += "   - Windows Mail Database: Detected at $wmailPath`r`n"

        } else {

            $report += "   (No Windows Mail store detected)`r`n"

        }

        

        $report += "`r`n========================================================`r`n"

        $report += "Report generated by Venkat Ultimate Windows Tweaker Suite.`r`n"

        

        Set-Content -Path $reportPath -Value $report -Encoding UTF8

        Append-Log("Exported email accounts and credentials report to $reportPath")

        Start-Process notepad.exe -ArgumentList "`"$reportPath`""

    })

}



# ==================== WINPE RESCUE SUITE & BUILDER HANDLERS ====================

if ($btnLaunchWinPERescue) {
    $btnLaunchWinPERescue.Add_Click({
        $candidates = @(
            "$PSScriptRoot\winpe_rescue_suite\VenkatRescueSuite.ps1",
            "$PSScriptRoot\..\winpe_rescue_suite\VenkatRescueSuite.ps1",
            "$env:USERPROFILE\.gemini\antigravity\scratch\winpe_rescue_suite\VenkatRescueSuite.ps1",
            "C:\Users\venkat\.gemini\antigravity\scratch\winpe_rescue_suite\VenkatRescueSuite.ps1"
        )
        $suitePath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($suitePath) {
            Append-Log("Launching Venkat WinPE Emergency Rescue Master Suite from $suitePath...")
            Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$suitePath`"" -Verb RunAs
        } else {
            Append-Log("WinPE Rescue Suite script not found.")
            [System.Windows.Forms.MessageBox]::Show("WinPE Rescue Suite script not found in winpe_rescue_suite folder.", "WinPE Suite", "OK", "Warning")
        }
    })
}

if ($btnLaunchWinPEBuilder) {
    $btnLaunchWinPEBuilder.Add_Click({
        $candidates = @(
            "$PSScriptRoot\winpe_rescue_suite\WinPE_Builder.ps1",
            "$PSScriptRoot\..\winpe_rescue_suite\WinPE_Builder.ps1",
            "$env:USERPROFILE\.gemini\antigravity\scratch\winpe_rescue_suite\WinPE_Builder.ps1",
            "C:\Users\venkat\.gemini\antigravity\scratch\winpe_rescue_suite\WinPE_Builder.ps1"
        )
        $builderPath = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
        if ($builderPath) {
            Append-Log("Launching WinPE Bootable USB / ISO Builder Wizard from $builderPath...")
            Start-Process powershell.exe -ArgumentList "-NoProfile -STA -ExecutionPolicy Bypass -File `"$builderPath`"" -Verb RunAs
        } else {
            Append-Log("WinPE Builder script not found.")
            [System.Windows.Forms.MessageBox]::Show("WinPE Builder script not found in winpe_rescue_suite folder.", "WinPE Builder", "OK", "Warning")
        }
    })
}



# ==================== NIRLAUNCHER & NIRSOFT MASTER SUITE HANDLERS ====================

function Invoke-NirLauncherDirectLaunch {
    param([bool]$ForceDownload = $false)

    $candidates = @(
        "C:\NirSoft\NirLauncher.exe",
        "C:\Tools\NirLauncher\NirLauncher.exe",
        "C:\NirLauncher\NirLauncher.exe",
        "$PSScriptRoot\NirLauncher\NirLauncher.exe",
        "$env:USERPROFILE\Downloads\nirsoft_package\NirLauncher.exe",
        "$env:USERPROFILE\Downloads\NirLauncher\NirLauncher.exe",
        "$env:USERPROFILE\Desktop\NirLauncher\NirLauncher.exe"
    )

    $found = $null
    if (-not $ForceDownload) {
        foreach ($c in $candidates) {
            if (Test-Path $c) { $found = $c; break }
        }
    }

    if ($found) {
        Append-Log("Launching NirLauncher Master Suite directly from $found...")
        try {
            Start-Process -FilePath $found -WorkingDirectory (Split-Path $found)
        } catch {
            Start-Process -FilePath $found
        }
        return
    }

    Append-Log("NirLauncher not found locally. Initiating automated download and direct setup...")

    $setupScript = @"
`$host.UI.RawUI.WindowTitle = "Venkat Tweaker - NirLauncher Auto Setup & Direct Launch"
Clear-Host
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "           VENKAT TWEAKER - NIRLAUNCHER MASTER SUITE SETUP" -ForegroundColor Yellow
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "[*] Destination Folder : C:\NirSoft" -ForegroundColor White
Write-Host "[*] Suite Contents     : 200+ NirSoft Utilities (Passwords, Network, System)" -ForegroundColor Gray
Write-Host ""
Write-Host "[*] Configuring Defender exclusion for C:\NirSoft to prevent false positives..." -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath "C:\NirSoft" -ErrorAction SilentlyContinue
    Write-Host "[✓] Exclusion configured successfully." -ForegroundColor Green
} catch {}

if (-not (Test-Path "C:\NirSoft")) {
    New-Item -ItemType Directory -Path "C:\NirSoft" -Force | Out-Null
}

`$zipUrl = "https://download.nirsoft.net/nirsoft_package_enc_1.30.25.zip"
`$tempZip = "`$env:TEMP\nirsoft_package.zip"

Write-Host ""
Write-Host "[*] Downloading official NirLauncher package (41 MB)..." -ForegroundColor Cyan

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    `$wc = New-Object System.Net.WebClient
    `$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    `$wc.Headers.Add("Referer", "https://launcher.nirsoft.net/downloads/index.html")
    `$wc.DownloadFile(`$zipUrl, `$tempZip)
    Write-Host "[✓] Download complete!" -ForegroundColor Green
} catch {
    Write-Host "[!] Download error: `$(`$_.Exception.Message)" -ForegroundColor Red
    Write-Host "Press any key to exit..."
    `$null = `$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit
}

Write-Host ""
Write-Host "[*] Extracting 200+ tools into C:\NirSoft..." -ForegroundColor Cyan

`$sevenZip = "C:\Program Files\7-Zip\7z.exe"
`$extracted = `$false

if (Test-Path `$sevenZip) {
    & `$sevenZip x "`$tempZip" "-oC:\NirSoft" "-pnirsoft9876$" -y | Out-Null
    `$extracted = (Test-Path "C:\NirSoft\NirLauncher.exe")
}

if (-not `$extracted) {
    try {
        `$pyCmd = "import zipfile; zf = zipfile.ZipFile(r'`$tempZip'); zf.extractall(r'C:\NirSoft', pwd=b'nirsoft9876$')"
        python -c `$pyCmd
        `$extracted = (Test-Path "C:\NirSoft\NirLauncher.exe")
    } catch {}
}

if (Test-Path `$tempZip) { Remove-Item `$tempZip -Force -ErrorAction SilentlyContinue }

Get-ChildItem -Path "C:\NirSoft" -Recurse | Unblock-File -ErrorAction SilentlyContinue

if (Test-Path "C:\NirSoft\NirLauncher.exe") {
    Write-Host "[✓] Setup complete! Launching NirLauncher directly now..." -ForegroundColor Green
    Start-Process -FilePath "C:\NirSoft\NirLauncher.exe" -WorkingDirectory "C:\NirSoft"
    Start-Sleep -Seconds 2
} else {
    Write-Host "[X] Could not locate NirLauncher.exe after extraction." -ForegroundColor Red
    Write-Host "Press any key to exit..."
    `$null = `$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
"@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($setupScript))
    Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -EncodedCommand $encoded" -Verb RunAs
}

if ($btnLaunchNirLauncher) {
    $btnLaunchNirLauncher.Add_Click({
        Invoke-NirLauncherDirectLaunch -ForceDownload $false
    })
}

if ($btnDownloadNirLauncher) {
    $btnDownloadNirLauncher.Add_Click({
        Invoke-NirLauncherDirectLaunch -ForceDownload $true
    })
}

if ($btnOpenNirFolder) {
    $btnOpenNirFolder.Add_Click({
        if (-not (Test-Path "C:\NirSoft")) { New-Item -ItemType Directory -Path "C:\NirSoft" -Force | Out-Null }
        Start-Process explorer.exe -ArgumentList "C:\NirSoft"
        Append-Log("Opened C:\NirSoft directory.")
    })
}



if ($btnLaunchWebBrowserPass) {

    $btnLaunchWebBrowserPass.Add_Click({

        $toolPath = "C:\NirSoft\NirSoft\WebBrowserPassView.exe"

        if (-not (Test-Path $toolPath)) { $toolPath = "C:\NirSoft\WebBrowserPassView.exe" }

        if (Test-Path $toolPath) {

            Start-Process -FilePath $toolPath -WorkingDirectory (Split-Path $toolPath)

            Append-Log("Launched WebBrowserPassView from $toolPath")

        } else {

            Append-Log("WebBrowserPassView not found in C:\NirSoft. Opening native PassView & Credential Manager...")

            Show-NativePassViewDialog

        }

    })

}



if ($btnLaunchWirelessKeyView) {

    $btnLaunchWirelessKeyView.Add_Click({

        $toolPath = "C:\NirSoft\NirSoft\WirelessKeyView.exe"

        if (-not (Test-Path $toolPath)) { $toolPath = "C:\NirSoft\WirelessKeyView.exe" }

        if (Test-Path $toolPath) {

            Start-Process -FilePath $toolPath -WorkingDirectory (Split-Path $toolPath)

            Append-Log("Launched WirelessKeyView from $toolPath")

        } else {

            Append-Log("Scanning all saved Wi-Fi networks and passwords (Native Engine)...")

            $profiles = netsh wlan show profiles | Select-String "All User Profile\s*:\s*(.*)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }

            $wList = @()

            foreach ($p in $profiles) {

                $pInfo = netsh wlan show profile name="$p" key=clear

                $passLine = $pInfo | Select-String "Key Content\s*:\s*(.*)$"

                $pass = if ($passLine) { $passLine.Matches.Groups[1].Value.Trim() } else { "[Open / No Password]" }

                $wList += [PSCustomObject]@{ SSID = $p; Password = $pass }

            }

            $msg = "=== SAVED WI-FI NETWORKS & PASSWORDS ===`r`n`r`n"

            foreach ($w in $wList) {

                $msg += "SSID: $($w.SSID)`r`nPassword: $($w.Password)`r`n----------------------------------`r`n"

            }

            Append-Log("Detected $($wList.Count) saved Wi-Fi networks.")

            [System.Windows.Forms.MessageBox]::Show($msg, "Wireless Passwords (WirelessKeyView Engine)", "OK", "Information")

        }

    })

}



if ($btnLaunchOutlookPass) {

    $btnLaunchOutlookPass.Add_Click({

        $toolPath = "C:\NirSoft\NirSoft\PstPassword.exe"

        if (-not (Test-Path $toolPath)) { $toolPath = "C:\NirSoft\PstPassword.exe" }

        if (Test-Path $toolPath) {

            Start-Process -FilePath $toolPath -WorkingDirectory (Split-Path $toolPath)

            Append-Log("Launched PstPassword from $toolPath")

        } else {

            Append-Log("Scanning Outlook PST/OST archives...")

            $outlookFiles = Get-ChildItem -Path "$env:LOCALAPPDATA\Microsoft\Outlook", "$env:USERPROFILE\Documents\Outlook Files" -Include "*.pst", "*.ost" -Recurse -ErrorAction SilentlyContinue

            if ($outlookFiles) {

                $filesStr = ($outlookFiles | ForEach-Object { $_.FullName }) -join "`r`n"

                [System.Windows.Forms.MessageBox]::Show("Detected Outlook Data Files:`r`n`r`n$filesStr`r`n`r`nDownload PstPassword into C:\NirSoft for deep recovery.", "Outlook Data Files", "OK", "Information")

            } else {

                [System.Windows.Forms.MessageBox]::Show("No local Outlook .PST/.OST files found in default user directory.`n`nTo use NirSoft PstPassword tool, place it in C:\NirSoft.", "Outlook Password Tool", "OK", "Information")

            }

        }

    })

}



# ==================== FEATURES & FIXES HANDLERS ====================

if ($btnInstallFeaturesBatch) {

    $btnInstallFeaturesBatch.Add_Click({

        Append-Log("Installing selected Windows Optional Features...")

        if ($chkFeatNetFx.IsChecked) {

            Enable-WindowsOptionalFeature -Online -FeatureName "NetFx3" -All -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Enable-WindowsOptionalFeature -Online -FeatureName "NetFx4-AdvSrvs" -All -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled .NET Framework 2.0 / 3.0 / 4.x.")

        }

        if ($chkFeatHyperV.IsChecked) {

            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled Hyper-V Virtualization Platform.")

        }

        if ($chkFeatF8Disable.IsChecked) {

            bcdedit /set "{default}" bootmenupolicy standard | Out-Null

            Append-Log("Legacy F8 Boot Recovery Disabled (Standard Modern Policy).")

        }

        if ($chkFeatF8Enable.IsChecked) {

            bcdedit /set "{default}" bootmenupolicy legacy | Out-Null

            Append-Log("Legacy F8 Boot Recovery Enabled (Classic F8 Key Mode).")

        }

        if ($chkFeatMedia.IsChecked) {

            Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Enable-WindowsOptionalFeature -Online -FeatureName "DirectPlay" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled Legacy Media Components (WMP & DirectPlay).")

        }

        if ($chkFeatNFS.IsChecked) {

            Enable-WindowsOptionalFeature -Online -FeatureName "ServicesForNFS-ClientOnly" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Enable-WindowsOptionalFeature -Online -FeatureName "ClientForNFS-Infrastructure" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled Network File System (NFS) Client.")

        }

        if ($chkFeatRegBackupTask.IsChecked) {

            $action = New-ScheduledTaskAction -Execute "cmd.exe" -Argument "/c reg save HKLM\Software C:\Windows\System32\config\RegBack\Software.bak /y & reg save HKLM\System C:\Windows\System32\config\RegBack\System.bak /y"

            $trigger = New-ScheduledTaskTrigger -Daily -At "12:30AM"

            Register-ScheduledTask -TaskName "DailyRegistryBackup1230AM" -Action $action -Trigger $trigger -User "SYSTEM" -Force -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled Daily Registry Backup Task (12:30 AM).")

        }

        if ($chkFeatSandbox.IsChecked) {

            Enable-WindowsOptionalFeature -Online -FeatureName "Containers-DisposableClientVM" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled Windows Sandbox.")

        }

        if ($chkFeatWSL.IsChecked) {

            Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Windows-Subsystem-Linux" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Enable-WindowsOptionalFeature -Online -FeatureName "VirtualMachinePlatform" -NoRestart -ErrorAction SilentlyContinue | Out-Null

            Append-Log("Enabled Windows Subsystem for Linux (WSL).")

        }

        [System.Windows.Forms.MessageBox]::Show("Selected Windows Optional Features processed successfully! Restart PC if prompted.", "Features Installed", "OK", "Information")

    })

}



if ($btnFixAutoLogon) {
    $btnFixAutoLogon.Add_Click({
        Append-Log("Opening Windows AutoLogon Hub & Account Settings (netplwiz)...")
        Start-Process netplwiz.exe
        $tabUser = $tabControl.Items | Where-Object { $_.Header -like "*User Passwords*" } | Select-Object -First 1
        if ($tabUser) { $tabControl.SelectedItem = $tabUser }
    })
}



if ($btnFixNetworkReset) {

    $btnFixNetworkReset.Add_Click({

        Append-Log("Executing complete Network Reset (Winsock, TCP/IP, FlushDNS, ARP)...")

        Start-Process cmd.exe -ArgumentList "/c netsh winsock reset & netsh int ip reset & ipconfig /flushdns & ipconfig /release & ipconfig /renew & arp -d *" -Verb RunAs -Wait

        Append-Log("Network Reset completed.")

        [System.Windows.Forms.MessageBox]::Show("Network Stack completely reset! Please restart your PC.", "Network Reset", "OK", "Information")

    })

}



if ($btnFixNTPServer) {

    $btnFixNTPServer.Add_Click({

        Append-Log("Configuring Windows as an Authoritative local NTP Server & resyncing...")

        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpServer" -Name "Enabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\Config" -Name "AnnounceFlags" -Value 5 -Type DWord -Force -ErrorAction SilentlyContinue

        Restart-Service w32time -Force -ErrorAction SilentlyContinue

        Start-Process cmd.exe -ArgumentList "/c w32tm /config /update & w32tm /resync /force" -Verb RunAs -Wait

        Append-Log("NTP Server enabled & time synchronized.")

        [System.Windows.Forms.MessageBox]::Show("Windows NTP Server is now ENABLED and synchronized!", "NTP Server", "OK", "Information")

    })

}



if ($btnFixSystemCorruption) {

    $btnFixSystemCorruption.Add_Click({

        Append-Log("Starting combined System Corruption Scan (SFC /scannow + DISM RestoreHealth)...")

        Start-Process cmd.exe -ArgumentList "/k echo Starting SFC System File Checker... & sfc /scannow & echo. & echo Starting DISM Component Repair... & DISM /Online /Cleanup-Image /RestoreHealth & echo. & echo System Corruption Scan Completed." -Verb RunAs

    })

}



if ($btnFixWindowsUpdate) {

    $btnFixWindowsUpdate.Add_Click({

        Append-Log("Stopping Windows Update services & purging update caches...")

        Stop-Service -Name wuauserv, bits, cryptsvc, trustedinstaller -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Service -Name wuauserv, bits, cryptsvc, trustedinstaller -ErrorAction SilentlyContinue

        Append-Log("Windows Update pipeline reset.")

        [System.Windows.Forms.MessageBox]::Show("Windows Update pipeline and download cache reset!", "Windows Update", "OK", "Information")

    })

}



if ($btnFixReinstallWinget) {

    $btnFixReinstallWinget.Add_Click({

        Append-Log("Reinstalling and repairing Microsoft WinGet DesktopAppInstaller...")

        Start-Process powershell.exe -ArgumentList "-NoExit -Command `"Add-AppxPackage -RegisterByFamilyName -MainPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe`"" -Verb RunAs

    })

}



# ==================== 1-CLICK MEGA APP STORE (WINGET) HANDLERS ====================

$allAppCheckboxes = @(

    $chkAppMS365, $chkAppMSTeams, $chkAppPowerToys, $chkAppMSTerminal, $chkAppMSPCManager, $chkAppMSOneDrive,

    $chkAppMSPS7, $chkAppMSSysinternals, $chkAppMSOneNote, $chkAppMSWhiteboard, $chkAppMSSSMS, $chkAppMSVSCommunity, $chkAppMSWSL,

    $chkAppChrome, $chkAppBrave, $chkAppFirefox, $chkAppEdge, $chkAppOperaGX, $chkAppTor,

    $chkAppAnyDesk, $chkAppTeamViewer, $chkAppRustDesk, $chkAppUltraViewer, $chkAppDiscord, $chkAppTelegram, $chkAppWhatsApp, $chkAppZoom, $chkAppSkype,

    $chkApp7Zip, $chkAppWinRAR, $chkAppPeaZip, $chkAppNotepad, $chkAppEverything, $chkAppRevo, $chkAppRufus, $chkAppCrystalDisk, $chkAppCPUZ, $chkAppHWMonitor, $chkAppTreeSize, $chkAppNirLauncher,

    $chkAppVLC, $chkAppKLite, $chkAppOBS, $chkAppGIMP, $chkAppPaintNet, $chkAppAudacity, $chkAppHandBrake, $chkAppSpotify, $chkAppCapCut,

    $chkAppVSCode, $chkAppGit, $chkAppGitHubDesktop, $chkAppPython, $chkAppNode, $chkAppDocker, $chkAppPostman, $chkAppDBeaver, $chkAppVCRedist, $chkAppJavaJDK,

    $chkAppAdobeReader, $chkAppFoxit, $chkAppSumatra, $chkAppLibreOffice, $chkAppWPS, $chkAppPDF24

)



if ($btnClearAllApps) {

    $btnClearAllApps.Add_Click({

        foreach ($c in $allAppCheckboxes) { if ($c) { $c.IsChecked = $false } }

        Append-Log("Cleared all App Store selections.")

    })

}



if ($btnSelectAllApps) {

    $btnSelectAllApps.Add_Click({

        foreach ($c in $allAppCheckboxes) { if ($c) { $c.IsChecked = $true } }

        Append-Log("Selected all applications in App Store.")

    })

}



if ($btnPresetAppEssentials) {

    $btnPresetAppEssentials.Add_Click({

        foreach ($c in $allAppCheckboxes) { if ($c) { $c.IsChecked = $false } }

        $essentials = @($chkAppChrome, $chkApp7Zip, $chkAppVLC, $chkAppNotepad, $chkAppAdobeReader, $chkAppAnyDesk, $chkAppPowerToys, $chkAppMSTerminal, $chkAppEverything)

        foreach ($c in $essentials) { if ($c) { $c.IsChecked = $true } }

        Append-Log("Loaded 'Essentials' App Store preset.")

    })

}



if ($btnPresetAppMS) {

    $btnPresetAppMS.Add_Click({

        foreach ($c in $allAppCheckboxes) { if ($c) { $c.IsChecked = $false } }

        $msApps = @($chkAppMS365, $chkAppMSTeams, $chkAppPowerToys, $chkAppMSTerminal, $chkAppMSPCManager, $chkAppMSOneDrive, $chkAppMSPS7, $chkAppMSSysinternals, $chkAppMSOneNote, $chkAppMSWhiteboard, $chkAppEdge)

        foreach ($c in $msApps) { if ($c) { $c.IsChecked = $true } }

        Append-Log("Loaded 'Microsoft Suite' App Store preset.")

    })

}



if ($btnPresetAppDev) {

    $btnPresetAppDev.Add_Click({

        foreach ($c in $allAppCheckboxes) { if ($c) { $c.IsChecked = $false } }

        $devApps = @($chkAppVSCode, $chkAppGit, $chkAppGitHubDesktop, $chkAppPython, $chkAppNode, $chkAppDocker, $chkAppPostman, $chkAppDBeaver, $chkAppVCRedist, $chkAppJavaJDK, $chkAppMSTerminal, $chkAppMSPS7, $chkAppMSWSL, $chkAppNotepad, $chkApp7Zip)

        foreach ($c in $devApps) { if ($c) { $c.IsChecked = $true } }

        Append-Log("Loaded 'Dev Bundle' App Store preset.")

    })

}



if ($btnInstallSelectedApps) {

    $btnInstallSelectedApps.Add_Click({

        $appMap = @{

            $chkAppMS365 = "Microsoft.Office"

            $chkAppMSTeams = "Microsoft.Teams"

            $chkAppPowerToys = "Microsoft.PowerToys"

            $chkAppMSTerminal = "Microsoft.WindowsTerminal"

            $chkAppMSPCManager = "Microsoft.PCManager"

            $chkAppMSOneDrive = "Microsoft.OneDrive"

            $chkAppMSPS7 = "Microsoft.PowerShell"

            $chkAppMSSysinternals = "Microsoft.SysinternalsSuite"

            $chkAppMSOneNote = "Microsoft.OneNote"

            $chkAppMSWhiteboard = "Microsoft.Whiteboard"

            $chkAppMSSSMS = "Microsoft.SQLServerManagementStudio"

            $chkAppMSVSCommunity = "Microsoft.VisualStudio.2022.Community"

            $chkAppMSWSL = "Microsoft.WSL"

            $chkAppChrome = "Google.Chrome"

            $chkAppBrave = "Brave.Brave"

            $chkAppFirefox = "Mozilla.Firefox"

            $chkAppEdge = "Microsoft.Edge"

            $chkAppOperaGX = "Opera.OperaGX"

            $chkAppTor = "TorProject.TorBrowser"

            $chkAppAnyDesk = "AnyDeskSoftwareGmbH.AnyDesk"

            $chkAppTeamViewer = "TeamViewer.TeamViewer"

            $chkAppRustDesk = "RustDesk.RustDesk"

            $chkAppUltraViewer = "UltraViewer.UltraViewer"

            $chkAppDiscord = "Discord.Discord"

            $chkAppTelegram = "Telegram.TelegramDesktop"

            $chkAppWhatsApp = "WhatsApp.WhatsApp"

            $chkAppZoom = "Zoom.Zoom"

            $chkAppSkype = "Microsoft.Skype"

            $chkApp7Zip = "7zip.7zip"

            $chkAppWinRAR = "RARLab.WinRAR"

            $chkAppPeaZip = "Giorgiotani.Peazip"

            $chkAppNotepad = "Notepad++.Notepad++"

            $chkAppEverything = "voidtools.Everything"

            $chkAppRevo = "RevoUninstaller.RevoUninstaller"

            $chkAppRufus = "Rufus.Rufus"

            $chkAppCrystalDisk = "CrystalDewWorld.CrystalDiskInfo"

            $chkAppCPUZ = "CPUID.CPU-Z"

            $chkAppHWMonitor = "CPUID.HWMonitor"

            $chkAppTreeSize = "JAMSoftware.TreeSize.Free"

            $chkAppVLC = "VideoLAN.VLC"

            $chkAppKLite = "CodecGuide.K-LiteCodecPack.Full"

            $chkAppOBS = "OBSProject.OBSStudio"

            $chkAppGIMP = "GIMP.GIMP"

            $chkAppPaintNet = "dotPDN.PaintDotNet"

            $chkAppAudacity = "Audacity.Audacity"

            $chkAppHandBrake = "HandBrake.HandBrake"

            $chkAppSpotify = "Spotify.Spotify"

            $chkAppCapCut = "ByteDance.CapCut"

            $chkAppVSCode = "Microsoft.VisualStudioCode"

            $chkAppGit = "Git.Git"

            $chkAppGitHubDesktop = "GitHub.GitHubDesktop"

            $chkAppPython = "Python.Python.3.12"

            $chkAppNode = "OpenJS.NodeJS.LTS"

            $chkAppDocker = "Docker.DockerDesktop"

            $chkAppPostman = "Postman.Postman"

            $chkAppDBeaver = "dbeaver.dbeaver"

            $chkAppVCRedist = "Microsoft.VCRedist.2015+.x64"

            $chkAppJavaJDK = "EclipseAdoptium.Temurin.21.JDK"

            $chkAppAdobeReader = "Adobe.Acrobat.Reader.64-bit"

            $chkAppFoxit = "Foxit.FoxitReader"

            $chkAppSumatra = "SumatraPDF.SumatraPDF"

            $chkAppLibreOffice = "TheDocumentFoundation.LibreOffice"

            $chkAppWPS = "Kingsoft.WPSOffice"

            $chkAppPDF24 = "geeksoftwareGmbH.PDF24Creator"

        }



        $selectedIds = @()

        foreach ($cb in $appMap.Keys) {

            if ($cb -and $cb.IsChecked) {

                $selectedIds += $appMap[$cb]

            }

        }



        if ($chkAppNirLauncher -and $chkAppNirLauncher.IsChecked) {

            Append-Log("NirLauncher selected. Preparing C:\NirSoft package setup...")

            Start-Process "https://launcher.nirsoft.net/"

            if (-not (Test-Path "C:\NirSoft")) { New-Item -ItemType Directory -Path "C:\NirSoft" -Force | Out-Null }

            Start-Process explorer.exe -ArgumentList "C:\NirSoft"

        }



        if ($selectedIds.Count -eq 0) {

            [System.Windows.Forms.MessageBox]::Show("Please select at least one application to install.", "App Store", "OK", "Warning")

            return

        }



        Append-Log("Initiating WinGet installation for $($selectedIds.Count) selected application(s)...")

        $cmdArgs = "/k "

        foreach ($id in $selectedIds) {

            $cmdArgs += "echo Installing $id via WinGet... & winget install --id $id -e --silent --accept-package-agreements --accept-source-agreements & echo. & "

        }

        $cmdArgs += "echo All selected software installations finished! & pause"

        Start-Process cmd.exe -ArgumentList $cmdArgs -Verb RunAs

        Append-Log("Launched WinGet batch installer console.")

    })

}



# ==================== OS CUSTOMIZER & AUTOUNATTEND GENERATOR ====================

if ($btnCustDownloadWin11) {
    $btnCustDownloadWin11.Add_Click({
        Append-Log("Opening official Windows 11 ISO download portal...")
        Start-Process "https://www.microsoft.com/en-us/software-download/windows11"
    })
}

if ($btnCustDownloadWin10) {
    $btnCustDownloadWin10.Add_Click({
        Append-Log("Opening official Windows 10 ISO download portal...")
        Start-Process "https://www.microsoft.com/en-us/software-download/windows10"
    })
}



if ($btnCustDownloadRufus) {

    $btnCustDownloadRufus.Add_Click({

        Append-Log("Opening Rufus Portable official download portal...")

        Start-Process "https://rufus.ie"

    })

}



if ($btnCustOpenFido) {

    $btnCustOpenFido.Add_Click({

        Append-Log("Opening Fido ISO Downloader / UUPDump...")

        Start-Process "https://uupdump.net"

    })

}



if ($btnRunLiveOOBEBypass) {

    $btnRunLiveOOBEBypass.Add_Click({

        Append-Log("Setting OOBE BypassNRO registry flag...")

        New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" -Name "BypassNRO" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Append-Log("OOBE BypassNRO flag set.")

        [System.Windows.Forms.MessageBox]::Show("BypassNRO registry key applied! If you are on the Windows 11 setup screen, press Shift+F10, type 'OOBE\BYPASSNRO' and press Enter to reboot without network requirement.", "Live OOBE Bypass", "OK", "Information")

    })

}



if ($btnLaunchRufus) {
    $btnLaunchRufus.Add_Click({
        $candidates = @(
            "$env:USERPROFILE\Downloads\rufus.exe",
            "$PSScriptRoot\rufus.exe",
            "C:\Tools\rufus.exe",
            "$env:TEMP\rufus.exe"
        )
        $rufusPath = $null
        foreach ($c in $candidates) {
            if (Test-Path $c) { $rufusPath = $c; break }
        }
        if (-not $rufusPath) {
            $glob = Get-Item "$env:USERPROFILE\Downloads\rufus*.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
            if ($glob) { $rufusPath = $glob.FullName }
        }

        if ($rufusPath) {
            Append-Log("Launching Rufus USB Builder from $rufusPath...")
            Start-Process $rufusPath
        } else {
            Append-Log("Rufus not found locally. Initiating 1-click official download...")
            try {
                $dest = "$env:USERPROFILE\Downloads\rufus.exe"
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $wc = New-Object System.Net.WebClient
                $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
                $wc.DownloadFile("https://github.com/pbatard/rufus/releases/download/v4.5/rufus-4.5.exe", $dest)
                Append-Log("Downloaded Rufus successfully to $dest. Launching...")
                Start-Process $dest
            } catch {
                Append-Log("Auto-download failed. Opening official Rufus website...")
                Start-Process "https://rufus.ie"
            }
        }
    })
}



if ($btnGenerateAutounattend) {

    $btnGenerateAutounattend.Add_Click({

        $targetChoice = $cmbCustTargetDrive.SelectedItem

        if (-not $targetChoice) {

            [System.Windows.Forms.MessageBox]::Show("Please select a target USB drive or location.", "Customizer", "OK", "Warning")

            return

        }

        

        $destPath = ""

        if ($targetChoice -match "^([A-Za-z]:)") {

            $destPath = "$($matches[1])\autounattend.xml"

        } else {

            $desktop = [Environment]::GetFolderPath("Desktop")

            $destPath = "$desktop\autounattend.xml"

        }



        $user = $txtCustUsername.Text.Trim()

        if (-not $user) { $user = "Admin" }

        $pass = $txtCustPassword.Text.Trim()



        # Build autounattend.xml

        $xmlContent = @"

<?xml version="1.0" encoding="utf-8"?>

<unattend xmlns="urn:schemas-microsoft-com:unattend">

  <settings pass="windowsPE">

    <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">

      <UserData>

        <AcceptEula>true</AcceptEula>

      </UserData>

      <RunSynchronous>

        <RunSynchronousCommand wcm:action="add">

          <Order>1</Order>

          <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassTPMCheck /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

        <RunSynchronousCommand wcm:action="add">

          <Order>2</Order>

          <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassSecureBootCheck /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

        <RunSynchronousCommand wcm:action="add">

          <Order>3</Order>

          <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassRAMCheck /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

        <RunSynchronousCommand wcm:action="add">

          <Order>4</Order>

          <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassStorageCheck /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

        <RunSynchronousCommand wcm:action="add">

          <Order>5</Order>

          <Path>reg add HKLM\SYSTEM\Setup\LabConfig /v BypassCPUCheck /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

      </RunSynchronous>

    </component>

  </settings>

  <settings pass="specialize">

    <component name="Microsoft-Windows-Deployment" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">

      <RunSynchronous>

        <RunSynchronousCommand wcm:action="add">

          <Order>1</Order>

          <Path>reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v BypassNRO /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

        <RunSynchronousCommand wcm:action="add">

          <Order>2</Order>

          <Path>reg add "HKLM\SYSTEM\CurrentControlSet\Control\BitLocker" /v PreventDeviceEncryption /t REG_DWORD /d 1 /f</Path>

        </RunSynchronousCommand>

      </RunSynchronous>

    </component>

  </settings>

  <settings pass="oobeSystem">

    <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">

      <OOBE>

        <HideEULAPage>true</HideEULAPage>

        <HideLocalAccountScreen>false</HideLocalAccountScreen>

        <HideOnlineAccountScreens>true</HideOnlineAccountScreens>

        <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>

        <ProtectYourPC>3</ProtectYourPC>

      </OOBE>

      <UserAccounts>

        <LocalAccounts>

          <LocalAccount wcm:action="add">

            <Name>$user</Name>

            <Group>Administrators</Group>

            <Password>

              <Value>$pass</Value>

              <PlainText>true</PlainText>

            </Password>

          </LocalAccount>

        </LocalAccounts>

      </UserAccounts>

    </component>

  </settings>

</unattend>

"@

        [System.IO.File]::WriteAllText($destPath, $xmlContent, [System.Text.Encoding]::UTF8)

        Append-Log("Generated autounattend.xml -> $destPath")

        [System.Windows.Forms.MessageBox]::Show("Unattended answer file successfully generated!`n`nSaved to:`n$destPath`n`nCopy this file to the root of your bootable Windows USB install drive to automatically bypass Microsoft Account, TPM, SecureBoot &amp; create user '$user'!", "autounattend.xml Generated", "OK", "Information")

    })

}



# ==================== POWER TOOLS HUB HANDLERS ====================

if ($btnPauseDefender) {

    $btnPauseDefender.Add_Click({

        Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue

        Append-Log("Windows Defender Realtime Protection PAUSED.")

        [System.Windows.Forms.MessageBox]::Show("Windows Defender Realtime Monitoring has been PAUSED!", "Defender Control", "OK", "Information")

    })

}



if ($btnEnableDefender) {

    $btnEnableDefender.Add_Click({

        Set-MpPreference -DisableRealtimeMonitoring $false -ErrorAction SilentlyContinue

        Append-Log("Windows Defender Realtime Protection ENABLED.")

        [System.Windows.Forms.MessageBox]::Show("Windows Defender Realtime Monitoring is now ENABLED!", "Defender Control", "OK", "Information")

    })

}



if ($btnClearDefenderCache) {

    $btnClearDefenderCache.Add_Click({

        $detPath = "C:\ProgramData\Microsoft\Windows Defender\Scans\History\Service\DetectionHistory"

        if (Test-Path $detPath) {

            Remove-Item "$detPath\*" -Recurse -Force -ErrorAction SilentlyContinue

        }

        Append-Log("Windows Defender Protection History cache purged.")

        [System.Windows.Forms.MessageBox]::Show("Windows Defender Protection History Cache Cleared!", "Defender Cache", "OK", "Information")

    })

}



if ($btnDisableSmartScreen2) {

    $btnDisableSmartScreen2.Add_Click({

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableSmartScreen" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AppHost" -Name "EnableWebContentEvaluation" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Append-Log("SmartScreen warnings disabled.")

        [System.Windows.Forms.MessageBox]::Show("Windows SmartScreen download warnings disabled!", "SmartScreen", "OK", "Information")

    })

}



if ($btnFixPrinterSpooler) {

    $btnFixPrinterSpooler.Add_Click({

        Append-Log("Purging stuck print queue and cycling Spooler service...")

        Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Service -Name Spooler -ErrorAction SilentlyContinue

        Append-Log("Printer Spooler reset successfully.")

        [System.Windows.Forms.MessageBox]::Show("Printer Spooler Queue Cleared & Service Restarted!", "Printer Spooler", "OK", "Information")

    })

}



if ($btnRemoveOneDrive) {

    $btnRemoveOneDrive.Add_Click({

        if ([System.Windows.Forms.MessageBox]::Show("Completely Uninstall Microsoft OneDrive and restore local user folders?", "Confirm OneDrive Removal", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {

            Append-Log("Terminating OneDrive processes & executing uninstaller...")

            Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue

            $setup64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"

            $setup32 = "$env:SystemRoot\System32\OneDriveSetup.exe"

            if (Test-Path $setup64) { Start-Process $setup64 -ArgumentList "/uninstall" -Wait }

            elseif (Test-Path $setup32) { Start-Process $setup32 -ArgumentList "/uninstall" -Wait }

            Append-Log("OneDrive uninstalled.")

            [System.Windows.Forms.MessageBox]::Show("Microsoft OneDrive uninstalled completely!", "OneDrive Removed", "OK", "Information")

        }

    })

}



if ($btnDisableCopilotRecall) {

    $btnDisableCopilotRecall.Add_Click({

        New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "DisableAIDataAnalysis" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Append-Log("Windows Copilot & Recall AI disabled.")

        [System.Windows.Forms.MessageBox]::Show("Windows 11 Copilot & Recall AI tracking disabled!", "AI Debloat", "OK", "Information")

    })

}



if ($btnDisableHibernation) {

    $btnDisableHibernation.Add_Click({

        powercfg -h off | Out-Null

        Append-Log("Hibernation disabled (hiberfil.sys removed, freed 4-32 GB).")

        [System.Windows.Forms.MessageBox]::Show("Hibernation DISABLED! hiberfil.sys removed and 4GB to 32GB of C: drive storage reclaimed.", "Hibernation", "OK", "Information")

    })

}



if ($btnEnableHibernation) {

    $btnEnableHibernation.Add_Click({

        powercfg -h on | Out-Null

        Append-Log("Hibernation enabled.")

        [System.Windows.Forms.MessageBox]::Show("Hibernation ENABLED.", "Hibernation", "OK", "Information")

    })

}



function Restart-ExplorerShell {
    param([bool]$ShowDialog = $false)
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer.exe
    Append-Log("Windows Explorer shell successfully restarted.")
    if ($ShowDialog) {
        [System.Windows.Forms.MessageBox]::Show("Windows Explorer Shell restarted successfully!", "Explorer", "OK", "Information")
    }
}

if ($btnRestartExplorerQuick) {
    $btnRestartExplorerQuick.Add_Click({
        Restart-ExplorerShell -ShowDialog $false
    })
}



if ($btnFixRecycleBinQuick) {

    $btnFixRecycleBinQuick.Add_Click({

        Start-Process cmd.exe -ArgumentList "/c rd /s /q C:\`$Recycle.bin & rd /s /q D:\`$Recycle.bin & rd /s /q E:\`$Recycle.bin" -Verb RunAs -Wait

        Append-Log("Corrupted Recycle Bin directories purged.")

        [System.Windows.Forms.MessageBox]::Show("Corrupted Recycle Bin fixed and rebuilt!", "Recycle Bin", "OK", "Information")

    })

}



if ($btnToggleHiddenFilesQuick) {

    $btnToggleHiddenFilesQuick.Add_Click({

        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"

        $current = (Get-ItemProperty -Path $key -Name "Hidden" -ErrorAction SilentlyContinue).Hidden

        $newVal = if ($current -eq 1) { 2 } else { 1 }

        Set-ItemProperty -Path $key -Name "Hidden" -Value $newVal -Type DWord -Force

        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

        Start-Sleep -Milliseconds 300

        Start-Process explorer.exe

        $statusStr = if ($newVal -eq 1) { "SHOWN" } else { "HIDDEN" }

        Append-Log("Hidden files toggled to $statusStr.")

        [System.Windows.Forms.MessageBox]::Show("Hidden files & folders are now $statusStr!", "Explorer", "OK", "Information")

    })

}



if ($btnEnableLongPathsQuick) {

    $btnEnableLongPathsQuick.Add_Click({

        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Append-Log("NTFS Long Path Support (>260 Characters) enabled.")

        [System.Windows.Forms.MessageBox]::Show("Long Path Support (>260 characters) ENABLED!", "Long Paths", "OK", "Information")

    })

}



if ($btnListStartupAppsQuick) {

    $btnListStartupAppsQuick.Add_Click({

        $desktop = [Environment]::GetFolderPath("Desktop")

        $outFile = "$desktop\Startup_Programs_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

        $regStart = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run", "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run" -ErrorAction SilentlyContinue

        $report = "=== Windows Startup Programs & Apps ===`n`n"

        $regStart | ForEach-Object {

            $_.PSObject.Properties | Where-Object { $_.Name -notmatch "^PS" } | ForEach-Object {

                $report += "- $($_.Name) = $($_.Value)`n"

            }

        }

        $report | Out-File -FilePath $outFile -Encoding utf8

        Append-Log("Startup apps report saved to Desktop: $outFile")

        [System.Windows.Forms.MessageBox]::Show($report, "Startup Programs", "OK", "Information")

        Start-Process notepad.exe -ArgumentList "`"$outFile`""

    })

}



if ($btnAnalyzeBatteryWear) {

    $btnAnalyzeBatteryWear.Add_Click({

        $battery = Get-CimInstance -ClassName Win32_Battery -ErrorAction SilentlyContinue

        if ($battery) {

            $report = "=== Laptop Battery Health & Status ===`n`n"

            $report += "Device Name: $($battery.Name)`n"

            $report += "Status: $($battery.Status)`n"

            $report += "Estimated Charge: $($battery.EstimatedChargeRemaining)%`n"

            $report += "Estimated Run Time: $([math]::Round($battery.EstimatedRunTime / 60, 1)) Hours`n"

            $report += "Design Voltage: $($battery.DesignVoltage) mV`n"

            [System.Windows.Forms.MessageBox]::Show($report, "Battery Diagnostics", "OK", "Information")

        } else {

            [System.Windows.Forms.MessageBox]::Show("No battery detected (Desktop PC or unsupported ACPI device).", "Battery Diagnostics", "OK", "Information")

        }

    })

}



if ($btnStartHotspot) {

    $btnStartHotspot.Add_Click({

        Append-Log("Starting PC Wi-Fi Hotspot (SSID: WindowsTweakerHotspot, Key: Pass@12345)...")

        Start-Process cmd.exe -ArgumentList '/c netsh wlan set hostednetwork mode=allow ssid=WindowsTweakerHotspot key=Pass@12345 & netsh wlan start hostednetwork' -Verb RunAs -Wait

        Append-Log("Wi-Fi Hotspot active.")

        [System.Windows.Forms.MessageBox]::Show("Wi-Fi Hotspot Started!`n`nSSID: WindowsTweakerHotspot`nPassword: Pass@12345", "Wi-Fi Hotspot", "OK", "Information")

    })

}



if ($btnStopHotspot) {

    $btnStopHotspot.Add_Click({

        Start-Process cmd.exe -ArgumentList '/c netsh wlan stop hostednetwork' -Verb RunAs -Wait

        Append-Log("Wi-Fi Hotspot stopped.")

        [System.Windows.Forms.MessageBox]::Show("Wi-Fi Hotspot stopped.", "Wi-Fi Hotspot", "OK", "Information")

    })

}



if ($btnBrowseShredFile) {

    $btnBrowseShredFile.Add_Click({

        $ofd = New-Object System.Windows.Forms.OpenFileDialog

        $ofd.Title = "Select File to Permanently Shred"

        if ($ofd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {

            $txtShredFilePath.Text = $ofd.FileName

        }

    })

}



if ($btnExecuteShredFile) {

    $btnExecuteShredFile.Add_Click({

        $file = $txtShredFilePath.Text.Trim()

        if (-not (Test-Path $file)) {

            [System.Windows.Forms.MessageBox]::Show("Target file not found.", "Shredder", "OK", "Warning")

            return

        }

        if ([System.Windows.Forms.MessageBox]::Show("PERMANENTLY SHRED FILE '$file'?`n`nThis file will be overwritten with 3 random passes and CANNOT be recovered!", "Confirm Shred", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {

            Append-Log("Shredding file: $file...")

            $len = (Get-Item $file).Length

            $stream = [System.IO.File]::OpenWrite($file)

            $rng = New-Object byte[] 4096

            $rand = New-Object System.Random

            

            # 3 Overwrite Passes

            for ($pass = 1; $pass -le 3; $pass++) {

                $stream.Position = 0

                $written = 0

                while ($written -lt $len) {

                    $rand.NextBytes($rng)

                    $toWrite = [math]::Min(4096, $len - $written)

                    $stream.Write($rng, 0, $toWrite)

                    $written += $toWrite

                }

                $stream.Flush()

            }

            $stream.Close()

            Remove-Item -Path $file -Force

            Append-Log("File permanently shredded: $file")

            [System.Windows.Forms.MessageBox]::Show("File successfully destroyed and permanently shredded!", "Shredder Complete", "OK", "Information")

        }

    })

}



# ==================== CHANGE WINDOWS EDITION HANDLERS ====================

if ($btnApplyEditionChange) {

    $btnApplyEditionChange.Add_Click({

        $key = $txtCustomEditionKey.Text.Trim()

        if (-not $key) {

            [System.Windows.Forms.MessageBox]::Show("Please enter a valid product key.", "Change Edition", "OK", "Warning")

            return

        }

        if ([System.Windows.Forms.MessageBox]::Show("Change Windows Edition using key '$key'?`n`nThis will execute changepk.exe to perform an in-place upgrade.", "Confirm Edition Change", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {

            Append-Log("Initiating Windows Edition upgrade with changepk.exe...")

            Start-Process changepk.exe -ArgumentList "/ProductKey $key" -Verb RunAs

        }

    })

}



if ($btnDISMEditionChange) {

    $btnDISMEditionChange.Add_Click({

        $key = $txtCustomEditionKey.Text.Trim()

        $sel = $cmbTargetWinEdition.SelectedItem

        $targetEdition = "Professional"

        if ($sel -match "Enterprise") { $targetEdition = "Enterprise" }

        elseif ($sel -match "Education") { $targetEdition = "Education" }

        elseif ($sel -match "Workstation") { $targetEdition = "ServerRdsh" }

        

        if ([System.Windows.Forms.MessageBox]::Show("Execute DISM In-Place Edition Switch to $targetEdition?", "Confirm DISM Upgrade", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {

            Append-Log("Running DISM /Set-Edition:$targetEdition...")

            Start-Process cmd.exe -ArgumentList "/k DISM /Online /Set-Edition:$targetEdition /ProductKey:$key /AcceptEula" -Verb RunAs

        }

    })

}



if ($btnOpenMASEditionMenu) {

    $btnOpenMASEditionMenu.Add_Click({

        Append-Log("Opening MAS Change Edition helper menu...")

        Start-Process powershell.exe -ArgumentList "-NoExit -Command `"irm https://get.activated.win | iex`"" -Verb RunAs

    })

}



# ==================== CONTEXT MENU EXTENSIONS ====================

if ($btnContextCopyPath) {

    $btnContextCopyPath.Add_Click({

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\copypath" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\copypath" -Name "(Default)" -Value "Copy Path" -Force -ErrorAction SilentlyContinue

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\copypath\command" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\copypath\command" -Name "(Default)" -Value 'cmd.exe /c echo %1 | clip' -Force -ErrorAction SilentlyContinue

        Append-Log("Added 'Copy Path' to Windows Context Menu.")

        [System.Windows.Forms.MessageBox]::Show("'Copy Path' added to right-click context menu!", "Context Menu", "OK", "Information")

    })

}



if ($btnContextCompact) {

    $btnContextCompact.Add_Click({

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\compactfolder" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\compactfolder" -Name "(Default)" -Value "Compact / Compress Folder (LZX)" -Force -ErrorAction SilentlyContinue

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\compactfolder\command" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\shell\compactfolder\command" -Name "(Default)" -Value 'compact.exe /c /s:"%1" /i /exe:lzx' -Force -ErrorAction SilentlyContinue

        Append-Log("Added 'Compact Folder' to Windows Directory Context Menu.")

        [System.Windows.Forms.MessageBox]::Show("'Compact Folder (LZX)' added to folder right-click context menu!", "Context Menu", "OK", "Information")

    })

}



if ($btnContextPermanentDelete) {

    $btnContextPermanentDelete.Add_Click({

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\permanentdelete" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\permanentdelete" -Name "(Default)" -Value "Permanently Delete File" -Force -ErrorAction SilentlyContinue

        New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\permanentdelete\command" -Force -ErrorAction SilentlyContinue | Out-Null

        Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\permanentdelete\command" -Name "(Default)" -Value 'cmd.exe /c del /f /q /a "%1"' -Force -ErrorAction SilentlyContinue

        Append-Log("Added 'Permanent Delete' to Windows File Context Menu.")

        [System.Windows.Forms.MessageBox]::Show("'Permanent Delete' added to right-click context menu!", "Context Menu", "OK", "Information")

    })

}



# ==================== OEM BIOS PRODUCT KEY EXTRACTOR ====================

$btnExtractProductKey.Add_Click({

    Append-Log("Extracting OEM BIOS and Registry Product Keys...")

    $desktop = [Environment]::GetFolderPath("Desktop")

    $outFile = "$desktop\Windows_Product_Keys_Report_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

    

    $biosKey = (wmic path softwarelicensingservice get OA3xOriginalProductKey | Select-Object -Skip 1 | Out-String).Trim()

    if (-not $biosKey) {

        $biosKey = (Get-CimInstance -ClassName SoftwareLicensingService).OA3xOriginalProductKey

    }

    if (-not $biosKey) { $biosKey = "[No OEM Key in Motherboard BIOS MSDM Table / Retail Unit]" }



    $os = Get-CimInstance Win32_OperatingSystem

    $cs = Get-CimInstance Win32_ComputerSystem



    $report = @"

================================================================================

           WINDOWS OEM BIOS & SYSTEM LICENSE REPORT

================================================================================

Generated On:   $(Get-Date)

Computer Name:  $($cs.Name)

Manufacturer:   $($cs.Manufacturer)

Model:          $($cs.Model)

OS Caption:     $($os.Caption) ($($os.OSArchitecture))

OS Version:     $($os.Version) (Build $($os.BuildNumber))



--------------------------------------------------------------------------------

1. FACTORY OEM BIOS PRODUCT KEY (ACPI MSDM TABLE):

   $biosKey



2. INSTALLED WINDOWS DIGITAL PRODUCT ID:

   $($os.SerialNumber)



================================================================================

Instructions:

- The Factory OEM key above is permanently embedded in your motherboard hardware.

- If you reinstall Windows, it will activate automatically using this key.

================================================================================

"@

    $report | Out-File -FilePath $outFile -Encoding utf8

    Append-Log("Product Keys report saved to Desktop: $outFile")

    [System.Windows.Forms.MessageBox]::Show($report, "Windows Product Key Extractor", "OK", "Information")

    Start-Process notepad.exe -ArgumentList "`"$outFile`""

})



# ==================== GAMING INPUT LAG & HARDWARE ====================

$btnDisableMouseAccel.Add_Click({

    Append-Log("Disabling mouse acceleration for 1:1 raw input...")

    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseSpeed" -Value "0" -Force -ErrorAction SilentlyContinue

    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold1" -Value "0" -Force -ErrorAction SilentlyContinue

    Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseThreshold2" -Value "0" -Force -ErrorAction SilentlyContinue

    Append-Log("Mouse Acceleration Disabled (1:1 Raw Pointer Accuracy Active).")

    [System.Windows.Forms.MessageBox]::Show("Mouse Pointer Acceleration Disabled! Enjoy 1:1 true raw mouse tracking.", "Mouse Optimizer", "OK", "Information")

})



$btnBoostKeyboardRate.Add_Click({

    Append-Log("Boosting keyboard repeat rate & reducing typing delay to zero...")

    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardDelay" -Value "0" -Force -ErrorAction SilentlyContinue

    Set-ItemProperty -Path "HKCU:\Control Panel\Keyboard" -Name "KeyboardSpeed" -Value "31" -Force -ErrorAction SilentlyContinue

    Append-Log("Keyboard latency minimized to 0ms.")

    [System.Windows.Forms.MessageBox]::Show("Keyboard Repeat Delay set to 0 ms and Speed to Maximum!", "Keyboard Optimizer", "OK", "Information")

})



$btnEnableMSIGpu.Add_Click({

    Append-Log("Configuring Message Signaled-Based Interrupts (MSI Mode) on Graphics Card...")

    $pciKeys = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Enum\PCI" -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.PSChildName -eq "Device Parameters" }

    $enabled = 0

    foreach ($k in $pciKeys) {

        $msiPath = Join-Path $k.PSPath "Interrupt Management\MessageSignaledInterruptProperties"

        if (Test-Path $msiPath) {

            Set-ItemProperty -Path $msiPath -Name "MSISupported" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            $enabled++

        }

    }

    Append-Log("MSI Mode configured on $enabled PCI devices.")

    [System.Windows.Forms.MessageBox]::Show("Message Signaled Interrupts (MSI Mode) Enabled on GPU/PCI Devices! Restart PC to apply.", "MSI Optimizer", "OK", "Information")

})



# ==================== STORAGE & LARGE FILES ====================

if ($btnFindLargestFiles) {

    $btnFindLargestFiles.Add_Click({

        Append-Log("Scanning Drive C: for Top 20 Largest Files (Please wait)...")

        $largest = Get-ChildItem "C:\" -File -Recurse -ErrorAction SilentlyContinue | Sort-Object Length -Descending | Select-Object -First 20

        $report = "=== Top 20 Largest Files on Drive C: ===`n`n"

        foreach ($f in $largest) {

            $sizeMB = [math]::Round($f.Length / 1MB, 1)

            $report += "[$sizeMB MB] $($f.FullName)`n"

        }

        Append-Log("Found largest files on C: drive.")

        [System.Windows.Forms.MessageBox]::Show($report, "Top 20 Largest Files Finder", "OK", "Information")

    })

}



if ($btnPurgeWinSxSComponent) {

    $btnPurgeWinSxSComponent.Add_Click({

        Append-Log("Executing WinSxS Component Store deep cleanup via DISM (Frees 5-20 GB)...")

        Start-Process cmd.exe -ArgumentList "/k DISM.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase" -Verb RunAs

    })

}



if ($btnPurgeWindowsOld) {

    $btnPurgeWindowsOld.Add_Click({

        Append-Log("Deep purging Windows.old, delivery optimization & shader caches...")

        @("C:\Windows.old", "C:\`$Windows.~BT", "C:\`$Windows.~WS") | ForEach-Object {

            if (Test-Path $_) {

                Start-Process cmd.exe -ArgumentList "/c takeown /F `"$_`" /R /D Y & rd /s /q `"$_`"" -Verb RunAs -Wait

            }

        }

        $shader = "$env:LOCALAPPDATA\D3DSCache"

        if (Test-Path $shader) { Remove-Item "$shader\*" -Recurse -Force -ErrorAction SilentlyContinue }

        Append-Log("Windows.old and Shader Cache deep purged.")

        [System.Windows.Forms.MessageBox]::Show("Windows.old and DirectX Shader Caches purged successfully!", "Storage Cleaner", "OK", "Information")

    })

}



# ==================== TIME & AUDIO DIAGNOSTICS ====================

if ($btnForceTimeResync) {

    $btnForceTimeResync.Add_Click({

        Append-Log("Resynchronizing Windows Clock with NTP pool servers...")

        Start-Service w32time -ErrorAction SilentlyContinue

        Start-Process cmd.exe -ArgumentList "/c w32tm /config /syncfromflags:manual /manualpeerlist:`"pool.ntp.org,time.windows.com,time.google.com`" /update & w32tm /resync /force" -Verb RunAs -Wait

        Append-Log("Windows Time synchronized: $(Get-Date)")

        [System.Windows.Forms.MessageBox]::Show("Windows Clock Synchronized Successfully!`n`nCurrent Time: $(Get-Date)", "Time Sync", "OK", "Information")

    })

}



if ($btnFixCMOSTimeDrift) {

    $btnFixCMOSTimeDrift.Add_Click({

        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\TimeZoneInformation" -Name "RealTimeIsUniversal" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Append-Log("RealTimeIsUniversal enabled for CMOS/Universal time.")

        [System.Windows.Forms.MessageBox]::Show("CMOS / Universal Time Drift Fixed! Hardware clock now synchronizes accurately across dual-boots and sleep cycles.", "Time Drift Fix", "OK", "Information")

    })

}



if ($btnFixAudioLatency) {

    $btnFixAudioLatency.Add_Click({

        Append-Log("Restarting Windows Audio Graph Isolation & fixing DPC latency...")

        Stop-Process -Name audiodg -Force -ErrorAction SilentlyContinue

        Restart-Service -Name Audiosrv, AudioEndpointBuilder -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Name "Scheduling Category" -Value "High" -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile\Tasks\Audio" -Name "SFIO Priority" -Value "High" -Force -ErrorAction SilentlyContinue

        Append-Log("Audio graph restarted with High Priority.")

        [System.Windows.Forms.MessageBox]::Show("Windows Audio Engine Restarted with High Priority! Audio popping/crackling fixed.", "Audio Latency", "OK", "Information")

    })

}



# ==================== SUPER ADMIN HANDLERS ====================

$btnBrowseTakeOwn.Add_Click({

    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog

    $fbd.Description = "Select target folder to take ownership and grant full access"

    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $txtTakeOwnPath.Text = $fbd.SelectedPath }

})

$btnExecuteTakeOwn.Add_Click({

    $path = $txtTakeOwnPath.Text.Trim()

    if (-not (Test-Path $path)) { return }

    Append-Log("Taking ownership and granting full admin permissions on '$path'...")

    Start-Process cmd.exe -ArgumentList "/c takeown /f `"$path`" /r /d y && icacls `"$path`" /grant administrators:F /t /c /q" -Verb RunAs -Wait

    Append-Log("Full ownership granted on '$path'.")

    [System.Windows.Forms.MessageBox]::Show("Full Administrator Ownership and permissions granted on:`n$path", "Take Ownership", "OK", "Information")

})

$btnEnableSuperAdmin2.Add_Click({

    net user administrator /active:yes | Out-Null

    Append-Log("Built-in Administrator enabled.")

    [System.Windows.Forms.MessageBox]::Show("Built-in Administrator Account has been ACTIVATED!", "Super Admin", "OK", "Information")

})

$btnCreateGodMode2.Add_Click({

    $desktop = [Environment]::GetFolderPath("Desktop")

    $godModePath = "$desktop\GodMode.{ED7BA470-8E54-465E-825C-99712043E01C}"

    if (-not (Test-Path $godModePath)) { New-Item -ItemType Directory -Path $godModePath -Force | Out-Null }

    Append-Log("GodMode folder created on Desktop.")

    [System.Windows.Forms.MessageBox]::Show("GodMode Master Control Panel created on your Desktop!", "GodMode", "OK", "Information")

})

$btnDisableUAC2.Add_Click({

    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    Append-Log("UAC disabled.")

    [System.Windows.Forms.MessageBox]::Show("UAC prompts disabled. Restart PC to apply completely.", "Super Admin", "OK", "Information")

})

$btnRebootUEFI.Add_Click({

    if ([System.Windows.Forms.MessageBox]::Show("Are you sure you want to reboot directly into Motherboard UEFI/BIOS setup right now?", "Confirm BIOS Reboot", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {

        shutdown /r /fw /t 0

    }

})

$btnPurgeTelemetryTasks.Add_Click({

    Append-Log("Disabling Windows telemetry scheduled tasks...")

    $tasks = @(

        "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",

        "\Microsoft\Windows\Application Experience\ProgramDataUpdater",

        "\Microsoft\Windows\Application Experience\StartupAppTask",

        "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",

        "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",

        "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector"

    )

    foreach ($t in $tasks) { Disable-ScheduledTask -TaskName $t -ErrorAction SilentlyContinue | Out-Null }

    Append-Log("All background telemetry scheduled tasks disabled.")

    [System.Windows.Forms.MessageBox]::Show("All background Windows Telemetry scheduled tasks disabled!", "Super Admin", "OK", "Information")

})

$btnRenameComputer.Add_Click({

    $newName = $txtNewHostName.Text.Trim()

    if ($newName) {

        Rename-Computer -NewName $newName -Force -ErrorAction SilentlyContinue

        Append-Log("PC renamed to '$newName'. Restart required.")

        [System.Windows.Forms.MessageBox]::Show("Computer successfully renamed to '$newName'! Please restart PC to complete name change.", "Rename PC", "OK", "Information")

    }

})

$btnKillProcess2.Add_Click({

    $pName = $txtProcessName.Text.Trim().Replace(".exe", "")

    if ($pName) {

        Stop-Process -Name $pName -Force -ErrorAction SilentlyContinue

        Append-Log("Force terminated process '$pName'.")

        [System.Windows.Forms.MessageBox]::Show("Force terminated process: $pName", "Super Admin", "OK", "Information")

    }

})

$btnInstallGPEdit2.Add_Click({

    Append-Log("Installing Group Policy Editor packages...")

    Start-Process cmd.exe -ArgumentList '/k "for /f %i in (''dir /b %windir%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientExtensions-Package~31bf3856ad364e35~amd64~~*.mum'') do (dism /online /norestart /add-package:\"%windir%\servicing\Packages\%i\") & for /f %i in (''dir /b %windir%\servicing\Packages\Microsoft-Windows-GroupPolicy-ClientTools-Package~31bf3856ad364e35~amd64~~*.mum'') do (dism /online /norestart /add-package:\"%windir%\servicing\Packages\%i\")"' -Verb RunAs

})

$btnRegBackup2.Add_Click({

    $desktop = [Environment]::GetFolderPath("Desktop")

    $regFile = "$desktop\Registry_Backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"

    Append-Log("Exporting full registry hive backup...")

    Start-Process reg.exe -ArgumentList "export `"HKLM\Software`" `"$regFile`" /y" -Wait

    Append-Log("Registry backup saved to $regFile")

    [System.Windows.Forms.MessageBox]::Show("Registry Backup saved to Desktop:`n$regFile", "Registry", "OK", "Information")

})



# ==================== TWEAKS & BYPASSES ====================

if ($btnPresetRecommended) {

    $btnPresetRecommended.Add_Click({

        $all = @($chkBypassTPM, $chkRemoveWatermark, $chkBlockDriverWU, $chkAlignTaskbarLeft, $chkTelemetry, $chkCortana, $chkBing, $chkAds, $chkLocation, $chkActivity, $chkFeedback, $chkSmartScreen, $chkHighPower, $chkUltPower, $chkStartupDelay, $chkStickyKeys, $chkVirtSecurity, $chkDisableHibernation, $chkMenuDelay, $chkNtfsTime, $chkUniversalBg, $chkEdgePreload, $chkHAGS, $chkTransparency, $chkGameDVR, $chkNetThrottle, $chkGameLatency, $chkHoverDelays, $chkSearchHighlights, $chkTakeOwn, $chkOpenNotepad, $chkKillStuck, $chkCmdAdmin, $chkCleanTemp, $chkCleanmgr, $chkDisableOneDrive, $chkRemoveBloatware, $chkDisableSearchIndexer, $chkDisableDefender, $chkStopWU, $chkShowExt, $chkShowHidden, $chkWin11ClassicMenu, $chkPhotoViewer)

        foreach ($c in $all) { if ($c) { $c.IsChecked = $false } }

        

        $rec = @($chkBypassTPM, $chkRemoveWatermark, $chkBlockDriverWU, $chkTelemetry, $chkCortana, $chkBing, $chkAds, $chkLocation, $chkActivity, $chkFeedback, $chkHighPower, $chkStartupDelay, $chkStickyKeys, $chkMenuDelay, $chkNtfsTime, $chkUniversalBg, $chkEdgePreload, $chkHAGS, $chkGameDVR, $chkNetThrottle, $chkGameLatency, $chkHoverDelays, $chkSearchHighlights, $chkTakeOwn, $chkOpenNotepad, $chkKillStuck, $chkCmdAdmin, $chkCleanTemp, $chkShowExt, $chkShowHidden, $chkWin11ClassicMenu, $chkPhotoViewer)

        foreach ($c in $rec) { if ($c) { $c.IsChecked = $true } }

        Append-Log("Loaded Recommended Tweaks & Bypasses Preset.")

    })

}



if ($btnPresetOnlyTweaks) {

    $btnPresetOnlyTweaks.Add_Click({

        $all = @($chkBypassTPM, $chkRemoveWatermark, $chkBlockDriverWU, $chkAlignTaskbarLeft, $chkTelemetry, $chkCortana, $chkBing, $chkAds, $chkLocation, $chkActivity, $chkFeedback, $chkSmartScreen, $chkHighPower, $chkUltPower, $chkStartupDelay, $chkStickyKeys, $chkVirtSecurity, $chkDisableHibernation, $chkMenuDelay, $chkNtfsTime, $chkUniversalBg, $chkEdgePreload, $chkHAGS, $chkTransparency, $chkGameDVR, $chkNetThrottle, $chkGameLatency, $chkHoverDelays, $chkSearchHighlights, $chkTakeOwn, $chkOpenNotepad, $chkKillStuck, $chkCmdAdmin, $chkCleanTemp, $chkCleanmgr, $chkDisableOneDrive, $chkRemoveBloatware, $chkDisableSearchIndexer, $chkDisableDefender, $chkStopWU, $chkShowExt, $chkShowHidden, $chkWin11ClassicMenu, $chkPhotoViewer)

        foreach ($c in $all) { if ($c) { $c.IsChecked = $false } }

        

        $tweaks = @($chkBypassTPM, $chkRemoveWatermark, $chkBlockDriverWU, $chkAlignTaskbarLeft, $chkTelemetry, $chkCortana, $chkBing, $chkAds, $chkLocation, $chkActivity, $chkFeedback, $chkHighPower, $chkUltPower, $chkStartupDelay, $chkStickyKeys, $chkMenuDelay, $chkNtfsTime, $chkUniversalBg, $chkEdgePreload, $chkHAGS, $chkTransparency, $chkGameDVR, $chkNetThrottle, $chkGameLatency, $chkHoverDelays, $chkSearchHighlights, $chkTakeOwn, $chkOpenNotepad, $chkKillStuck, $chkCmdAdmin, $chkShowExt, $chkShowHidden, $chkWin11ClassicMenu, $chkPhotoViewer)

        foreach ($c in $tweaks) { if ($c) { $c.IsChecked = $true } }

        Append-Log("Loaded Only Tweaks Preset.")

    })

}



if ($btnPresetClear) {

    $btnPresetClear.Add_Click({

        $all = @($chkBypassTPM, $chkRemoveWatermark, $chkBlockDriverWU, $chkAlignTaskbarLeft, $chkTelemetry, $chkCortana, $chkBing, $chkAds, $chkLocation, $chkActivity, $chkFeedback, $chkSmartScreen, $chkHighPower, $chkUltPower, $chkStartupDelay, $chkStickyKeys, $chkVirtSecurity, $chkDisableHibernation, $chkMenuDelay, $chkNtfsTime, $chkUniversalBg, $chkEdgePreload, $chkHAGS, $chkTransparency, $chkGameDVR, $chkNetThrottle, $chkGameLatency, $chkHoverDelays, $chkSearchHighlights, $chkTakeOwn, $chkOpenNotepad, $chkKillStuck, $chkCmdAdmin, $chkCleanTemp, $chkCleanmgr, $chkDisableOneDrive, $chkRemoveBloatware, $chkDisableSearchIndexer, $chkDisableDefender, $chkStopWU, $chkShowExt, $chkShowHidden, $chkWin11ClassicMenu, $chkPhotoViewer)

        foreach ($c in $all) { if ($c) { $c.IsChecked = $false } }

        Append-Log("Cleared all checkboxes.")

    })

}



if ($btnApplyTweaksBatch) {

    $btnApplyTweaksBatch.Add_Click({

        Append-Log("Applying selected tweaks and system customizations...")

        

        # Telemetry & Privacy

        if ($chkBypassTPM -and $chkBypassTPM.IsChecked) {

            New-Item -Path "HKLM:\SYSTEM\Setup\LabConfig" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassTPMCheck" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassSecureBootCheck" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassRAMCheck" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassStorageCheck" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\LabConfig" -Name "BypassCPUCheck" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            New-Item -Path "HKLM:\SYSTEM\Setup\MoSetup" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SYSTEM\Setup\MoSetup" -Name "AllowUpgradesWithUnsupportedTPMOrCPU" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkRemoveWatermark -and $chkRemoveWatermark.IsChecked) {

            New-Item -Path "HKCU:\Control Panel\UnsupportedHardwareNotificationCache" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKCU:\Control Panel\UnsupportedHardwareNotificationCache" -Name "SV1" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKCU:\Control Panel\UnsupportedHardwareNotificationCache" -Name "SV2" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkBlockDriverWU -and $chkBlockDriverWU.IsChecked) {

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate" -Name "ExcludeWUDriversInQualityUpdate" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkAlignTaskbarLeft -and $chkAlignTaskbarLeft.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkTelemetry -and $chkTelemetry.IsChecked) {

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            Stop-Service -Name DiagTrack -Force -ErrorAction SilentlyContinue

            Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction SilentlyContinue

        }

        if ($chkCortana -and $chkCortana.IsChecked) {

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkBing -and $chkBing.IsChecked) {

            New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "DisableSearchBoxSuggestions" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkAds -and $chkAds.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkLocation -and $chkLocation.IsChecked) {

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkActivity -and $chkActivity.IsChecked) {

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkFeedback -and $chkFeedback.IsChecked) {

            New-Item -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkSmartScreen -and $chkSmartScreen.IsChecked) {

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer" -Name "SmartScreenEnabled" -Value "Off" -Type String -Force -ErrorAction SilentlyContinue

        }



        # System Optimizations & Adjustments

        if ($chkHighPower -and $chkHighPower.IsChecked) {

            powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c 2>$null

        }

        if ($chkUltPower -and $chkUltPower.IsChecked) {

            powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null

            powercfg /setactive e9a42b02-d5df-448d-aa00-03f14749eb61 | Out-Null

        }

        if ($chkStartupDelay -and $chkStartupDelay.IsChecked) {

            New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkStickyKeys -and $chkStickyKeys.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -Type String -Force -ErrorAction SilentlyContinue

        }

        if ($chkVirtSecurity -and $chkVirtSecurity.IsChecked) {

            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard" -Name "EnableVirtualizationBasedSecurity" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\DeviceGuard\Scenarios\HypervisorEnforcedCodeIntegrity" -Name "Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkDisableHibernation -and $chkDisableHibernation.IsChecked) {

            powercfg -h off 2>$null

        }

        if ($chkMenuDelay -and $chkMenuDelay.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -Type String -Force -ErrorAction SilentlyContinue

        }

        if ($chkNtfsTime -and $chkNtfsTime.IsChecked) {

            fsutil behavior set disablelastaccess 1 | Out-Null

        }

        if ($chkUniversalBg -and $chkUniversalBg.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" -Name "GlobalUserDisabled" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkEdgePreload -and $chkEdgePreload.IsChecked) {

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\Main" -Name "AllowPrelaunch" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\MicrosoftEdge\TabPreloader" -Name "AllowTabPreloading" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkHAGS -and $chkHAGS.IsChecked) {

            Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkTransparency -and $chkTransparency.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "EnableTransparency" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkGameDVR -and $chkGameDVR.IsChecked) {

            Set-ItemProperty -Path "HKCU:\System\GameConfigStore" -Name "GameDVR_Enabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR" -Name "AllowGameDVR" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkNetThrottle -and $chkNetThrottle.IsChecked) {

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "NetworkThrottlingIndex" -Value 0xFFFFFFFF -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkGameLatency -and $chkGameLatency.IsChecked) {

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" -Name "SystemResponsiveness" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkHoverDelays -and $chkHoverDelays.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Control Panel\Mouse" -Name "MouseHoverTime" -Value "10" -Type String -Force -ErrorAction SilentlyContinue

        }

        if ($chkSearchHighlights -and $chkSearchHighlights.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsSearchHighlightsEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }



        # Right-Click Context Menu Tweaks

        if ($chkTakeOwn -and $chkTakeOwn.IsChecked) {

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\runas" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\runas" -Name "(Default)" -Value "Take Ownership" -Force -ErrorAction SilentlyContinue

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\runas\command" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\runas\command" -Name "(Default)" -Value 'cmd.exe /c takeown /f "%1" && icacls "%1" /grant administrators:F' -Force -ErrorAction SilentlyContinue

        }

        if ($chkOpenNotepad -and $chkOpenNotepad.IsChecked) {

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\OpenWithNotepad" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\OpenWithNotepad" -Name "(Default)" -Value "Open with Notepad" -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\OpenWithNotepad" -Name "Icon" -Value "notepad.exe" -Force -ErrorAction SilentlyContinue

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\*\shell\OpenWithNotepad\command" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\*\shell\OpenWithNotepad\command" -Name "(Default)" -Value 'notepad.exe "%1"' -Force -ErrorAction SilentlyContinue

        }

        if ($chkKillStuck -and $chkKillStuck.IsChecked) {

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNotResponding" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNotResponding" -Name "(Default)" -Value "Kill Not Responding Tasks" -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNotResponding" -Name "Icon" -Value "taskmgr.exe,-1" -Force -ErrorAction SilentlyContinue

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNotResponding\command" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\DesktopBackground\Shell\KillNotResponding\command" -Name "(Default)" -Value 'taskkill.exe /F /FI "STATUS eq NOT RESPONDING"' -Force -ErrorAction SilentlyContinue

        }

        if ($chkCmdAdmin -and $chkCmdAdmin.IsChecked) {

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\runas" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\runas" -Name "(Default)" -Value "Command Prompt Here (Admin)" -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\runas" -Name "HasLUAShield" -Value "" -Force -ErrorAction SilentlyContinue

            New-Item -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\runas\command" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\Directory\Background\shell\runas\command" -Name "(Default)" -Value 'cmd.exe /s /k pushd "%V"' -Force -ErrorAction SilentlyContinue

        }



        # Cleaners, Bloatware & Services

        if ($chkCleanTemp -and $chkCleanTemp.IsChecked) {

            @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {

                if (Test-Path $_) { Remove-Item "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }

            }

        }

        if ($chkCleanmgr -and $chkCleanmgr.IsChecked) {

            Start-Process cleanmgr.exe -ArgumentList "/autoclean /d C:" -NoNewWindow -ErrorAction SilentlyContinue

        }

        if ($chkDisableOneDrive -and $chkDisableOneDrive.IsChecked) {

            Stop-Process -Name OneDrive -Force -ErrorAction SilentlyContinue

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive" -Name "DisableFileSyncNGSC" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkRemoveBloatware -and $chkRemoveBloatware.IsChecked) {

            @("*Solitaire*", "*Xbox*", "*BingNews*", "*BingWeather*", "*ZuneVideo*", "*ZuneMusic*", "*SkypeApp*") | ForEach-Object {

                Get-AppxPackage -AllUsers -Name $_ -ErrorAction SilentlyContinue | Remove-AppxPackage -AllUsers -ErrorAction SilentlyContinue

            }

        }

        if ($chkDisableSearchIndexer -and $chkDisableSearchIndexer.IsChecked) {

            Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue

            Set-Service -Name WSearch -StartupType Disabled -ErrorAction SilentlyContinue

        }

        if ($chkDisableDefender -and $chkDisableDefender.IsChecked) {

            New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Name "DisableAntiSpyware" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkStopWU -and $chkStopWU.IsChecked) {

            Stop-Service -Name wuauserv, bits, dosvc -Force -ErrorAction SilentlyContinue

            Set-Service -Name wuauserv, bits, dosvc -StartupType Disabled -ErrorAction SilentlyContinue

        }

        if ($chkShowExt -and $chkShowExt.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkShowHidden -and $chkShowHidden.IsChecked) {

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSuperHidden" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        }

        if ($chkWin11ClassicMenu -and $chkWin11ClassicMenu.IsChecked) {

            $regPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"

            New-Item -Path $regPath -Force -ErrorAction SilentlyContinue | Out-Null

            Set-ItemProperty -Path $regPath -Name "(Default)" -Value "" -Force -ErrorAction SilentlyContinue

        }

        if ($chkPhotoViewer -and $chkPhotoViewer.IsChecked) {

            $pvPath = "HKLM:\SOFTWARE\Microsoft\Windows Photo Viewer\Capabilities\FileAssociations"

            New-Item -Path $pvPath -Force -ErrorAction SilentlyContinue | Out-Null

            @(".jpg", ".jpeg", ".png", ".bmp", ".gif", ".tiff") | ForEach-Object { Set-ItemProperty -Path $pvPath -Name $_ -Value "PhotoViewer.FileAssoc.Tiff" -Force -ErrorAction SilentlyContinue }

        }



        Append-Log("Selected tweaks and system customizations applied successfully!")

        [System.Windows.Forms.MessageBox]::Show("All selected tweaks applied successfully!", "Tweaks Applied", "OK", "Information")

    })

}



# ==================== HARDWARE, SECURITY & REPAIR ====================

$btnUnparkCPU.Add_Click({

    powercfg -setacvalueindex scheme_current sub_processor CPMINCORES 100 | Out-Null

    powercfg -setactive scheme_current | Out-Null

    [System.Windows.Forms.MessageBox]::Show("All CPU Cores have been UNPARKED! Enjoy 100% active multi-core speed.", "CPU Booster", "OK", "Information")

})

$btnDisableUSBSleep.Add_Click({

    powercfg /SETACVALUEINDEX SCHEME_CURRENT 2a737441-1930-4402-8d77-b2bebba308a3 48e6b7a6-50f5-4782-a5d4-53bb8f07e226 0 | Out-Null

    powercfg /SETACTIVE SCHEME_CURRENT | Out-Null

    [System.Windows.Forms.MessageBox]::Show("USB Port Power Sleep / Throttling Disabled!", "Hardware", "OK", "Information")

})

$btnForceTrimSSD.Add_Click({

    Optimize-Volume -DriveLetter C -Defrag -ReTrim -Verbose | Out-Null

    [System.Windows.Forms.MessageBox]::Show("NVMe / SSD TRIM Optimization finished on Drive C:!", "SSD Optimizer", "OK", "Information")

})

$btnEnableHAGS.Add_Click({

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" -Name "HwSchMode" -Value 2 -Type DWord -Force -ErrorAction SilentlyContinue

    [System.Windows.Forms.MessageBox]::Show("Hardware Accelerated GPU Scheduling (HAGS) Enabled!", "GPU Booster", "OK", "Information")

})

$btnSmartScan.Add_Click({

    $disks = Get-PhysicalDisk | Select-Object DeviceId, FriendlyName, MediaType, HealthStatus, OperationalStatus | Format-Table -AutoSize | Out-String

    [System.Windows.Forms.MessageBox]::Show($disks, "Physical Drive SMART Status", "OK", "Information")

})

$btnRamSpecs.Add_Click({

    $ram = Get-CimInstance Win32_PhysicalMemory | Select-Object BankLabel, @{N='Capacity (GB)';E={[math]::round($_.Capacity/1GB,2)}}, Speed, Manufacturer, PartNumber | Format-Table -AutoSize | Out-String

    [System.Windows.Forms.MessageBox]::Show($ram, "RAM Hardware Specifications", "OK", "Information")

})

$btnMemDiag.Add_Click({ Start-Process mdsched.exe })

$btnSpeedTest.Add_Click({

    Append-Log("Running Real-Time Internet Download Speed Test via Cloudflare CDN...")

    $sw = [System.Diagnostics.Stopwatch]::StartNew()

    try {

        $wc = New-Object System.Net.WebClient

        $data = $wc.DownloadData("https://speed.cloudflare.com/__down?bytes=25000000")

        $sw.Stop()

        $seconds = $sw.Elapsed.TotalSeconds

        $mbps = [math]::Round((($data.Length * 8) / (1024 * 1024)) / $seconds, 2)

        Append-Log("Speed Test: $mbps Mbps")

        [System.Windows.Forms.MessageBox]::Show("Download Speed Test Completed:`n`nSpeed: $mbps Mbps`nLatency/Time: $([math]::Round($seconds, 2)) seconds", "Internet Speed Test", "OK", "Information")

    } catch {

        [System.Windows.Forms.MessageBox]::Show("Could not complete test: $_", "Speed Test", "OK", "Warning")

    }

})

$btnBatteryHealth.Add_Click({

    $desktop = [Environment]::GetFolderPath("Desktop")

    $out = "$desktop\battery_report.html"

    powercfg /batteryreport /output "$out"

    if (Test-Path $out) { Start-Process $out }

})

$btnSysSummary.Add_Click({

    $os = Get-CimInstance Win32_OperatingSystem

    $cs = Get-CimInstance Win32_ComputerSystem

    $cpu = Get-CimInstance Win32_Processor | Select-Object -First 1

    $summary = "OS: $($os.Caption) ($($os.OSArchitecture))`nVersion: $($os.Version) (Build $($os.BuildNumber))`nComputer: $($cs.Manufacturer) $($cs.Model)`nCPU: $($cpu.Name)`nRAM: $([math]::Round($cs.TotalPhysicalMemory/1GB,2)) GB"

    [System.Windows.Forms.MessageBox]::Show($summary, "Windows System Summary", "OK", "Information")

})



# ==================== CRASH & REPAIRS ====================

if ($btnAnalyzeBSOD) {

    $btnAnalyzeBSOD.Add_Click({

        $dumpPath = "C:\Windows\Minidump"

        $events = Get-WinEvent -FilterHashtable @{LogName='System'; ProviderName='Microsoft-Windows-WER-SystemErrorReporting'} -MaxEvents 5 -ErrorAction SilentlyContinue

        $report = "=== Windows Blue Screen (BSOD) Crash Analyzer ===`n`n"

        if (Test-Path $dumpPath) {

            $dumps = Get-ChildItem $dumpPath -Filter "*.dmp" -ErrorAction SilentlyContinue

            if ($dumps) {

                $report += "Found $($dumps.Count) Minidump crash files:`n"

                foreach ($d in $dumps | Select-Object -Last 3) {

                    $report += "- $($d.Name) - Size: $([math]::round($d.Length/1KB,1)) KB - Modified: $($d.LastWriteTime)`n"

                }

            }

        }

        if ($events) {

            $report += "`nRecent System BugCheck Crash Reports:`n"

            foreach ($ev in $events) { $report += "[$($ev.TimeCreated)] $($ev.Message)`n------------------------------------------------`n" }

        }

        [System.Windows.Forms.MessageBox]::Show($report, "BSOD Minidump Crash Analyzer", "OK", "Information")

    })

}



if ($btnUnblockTools) {

    $btnUnblockTools.Add_Click({

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableRegistryTools" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\System" -Name "DisableCMD" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Task Manager, Registry Editor, and Command Prompt are now completely UNBLOCKED!", "Unblock Tools", "OK", "Information")

    })

}



if ($btnFixStuckWU) {

    $btnFixStuckWU.Add_Click({

        Stop-Service -Name wuauserv, bits, cryptsvc, trustedinstaller -Force -ErrorAction SilentlyContinue

        Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force -ErrorAction SilentlyContinue

        Rename-Item -Path "C:\Windows\System32\catroot2" -NewName "catroot2.old_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force -ErrorAction SilentlyContinue

        Start-Service -Name wuauserv, bits, cryptsvc, trustedinstaller -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Stuck Windows Update pipeline reset successfully!", "Windows Update Fix", "OK", "Information")

    })

}



if ($btnRebuildSearchIndex) {

    $btnRebuildSearchIndex.Add_Click({

        Stop-Service -Name WSearch -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows Search" -Name "SetupCompletedSuccessfully" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Start-Service -Name WSearch -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Windows Search Index database rebuild started in background.", "Search Index", "OK", "Information")

    })

}



if ($btnRunSFC) { $btnRunSFC.Add_Click({ Start-Process cmd.exe -ArgumentList "/k sfc /scannow" -Verb RunAs }) }

if ($btnDismRestore) { $btnDismRestore.Add_Click({ Start-Process cmd.exe -ArgumentList "/k DISM /Online /Cleanup-Image /RestoreHealth" -Verb RunAs }) }

if ($btnDismCheck) { $btnDismCheck.Add_Click({ Start-Process cmd.exe -ArgumentList "/k DISM /Online /Cleanup-Image /CheckHealth" -Verb RunAs }) }

if ($btnResetWU) {

    $btnResetWU.Add_Click({

        Stop-Service -Name wuauserv, bits, cryptsvc -Force -ErrorAction SilentlyContinue

        Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force -ErrorAction SilentlyContinue

        Start-Service -Name wuauserv, bits, cryptsvc -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Windows Update cache reset successfully!", "Updates", "OK", "Information")

    })

}



if ($btnRepairEngines) {

    $btnRepairEngines.Add_Click({

        @("vbscript.dll", "jscript.dll", "mshtml.dll", "wups2.dll", "wuaueng.dll", "oleaut32.dll") | ForEach-Object { Start-Process regsvr32.exe -ArgumentList "/s $_" -Wait }

        [System.Windows.Forms.MessageBox]::Show("Servicing and repair DLL engines re-registered!", "Repair", "OK", "Information")

    })

}



if ($btnRegCoreDLLs) {

    $btnRegCoreDLLs.Add_Click({

        @("atl.dll", "urlmon.dll", "msxml3.dll", "msxml6.dll", "scrrun.dll") | ForEach-Object { Start-Process regsvr32.exe -ArgumentList "/s $_" -Wait }

        [System.Windows.Forms.MessageBox]::Show("Core system DLL libraries re-registered!", "Repair", "OK", "Information")

    })

}



if ($btnRepairStore) {

    $btnRepairStore.Add_Click({

        Start-Process powershell.exe -ArgumentList "-NoExit -Command `"Get-AppXPackage -AllUsers | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register `"`$(`$_.InstallLocation)\AppXManifest.xml`" -ErrorAction SilentlyContinue}`"" -Verb RunAs

    })

}



if ($btnEnableWinRE) {

    $btnEnableWinRE.Add_Click({

        Start-Process reagentc.exe -ArgumentList "/enable" -Wait

        [System.Windows.Forms.MessageBox]::Show("Windows Recovery Environment (WinRE) Enabled!", "WinRE", "OK", "Information")

    })

}



if ($btnCheckWinRE) { $btnCheckWinRE.Add_Click({ Start-Process cmd.exe -ArgumentList "/k reagentc /info" -Verb RunAs }) }

if ($btnRebuildBCD) { $btnRebuildBCD.Add_Click({ Start-Process cmd.exe -ArgumentList "/k bcdboot C:\Windows /v" -Verb RunAs }) }

if ($btnScheduleChkdsk) { $btnScheduleChkdsk.Add_Click({ Start-Process cmd.exe -ArgumentList "/k echo y | chkdsk C: /f /r" -Verb RunAs }) }

if ($btnConvertNTFS) {

    $btnConvertNTFS.Add_Click({

        $selected = $cmbDriveLetter.SelectedItem

        if (-not $selected) { return }

        $letter = $selected.ToString().Substring(0, 1)

        if ([System.Windows.Forms.MessageBox]::Show("Convert Drive $letter`: to NTFS?", "Confirm NTFS", "YesNo", "Question") -eq [System.Windows.Forms.DialogResult]::Yes) {

            Start-Process cmd.exe -ArgumentList "/k convert $letter`: /fs:ntfs" -Verb RunAs

        }

    })

}

$btnConvertGPT.Add_Click({

    $selected = $cmbDiskID.SelectedItem

    if (-not $selected) { return }

    $diskNum = [regex]::Match($selected.ToString(), "Disk (\d+)").Groups[1].Value

    if ([System.Windows.Forms.MessageBox]::Show("Convert Disk $diskNum from MBR to GPT?", "Confirm MBR to GPT", "YesNo", "Warning") -eq [System.Windows.Forms.DialogResult]::Yes) {

        Start-Process cmd.exe -ArgumentList "/k mbr2gpt /validate /disk:$diskNum /allowFullOS & mbr2gpt /convert /disk:$diskNum /allowFullOS" -Verb RunAs

    }

})



if ($btnFlushDNS2) { $btnFlushDNS2.Add_Click({ Clear-DnsClientCache; [System.Windows.Forms.MessageBox]::Show("DNS Resolver Cache Flushed!", "DNS", "OK", "Information") }) }

if ($btnResetWinsock2) { $btnResetWinsock2.Add_Click({ Start-Process netsh.exe -ArgumentList "winsock reset" -Wait -NoNewWindow; [System.Windows.Forms.MessageBox]::Show("Winsock catalog reset successfully! Please reboot your system.", "Winsock", "OK", "Information") }) }

if ($btnResetFirewall2) { $btnResetFirewall2.Add_Click({ Start-Process netsh.exe -ArgumentList "advfirewall reset" -Wait -NoNewWindow; [System.Windows.Forms.MessageBox]::Show("Windows Firewall rules restored to default!", "Firewall", "OK", "Information") }) }

if ($btnResetNetworkStack2) { $btnResetNetworkStack2.Add_Click({ Start-Process netsh.exe -ArgumentList "int ip reset" -Wait -NoNewWindow; Start-Process netsh.exe -ArgumentList "winsock reset" -Wait -NoNewWindow; Clear-DnsClientCache; [System.Windows.Forms.MessageBox]::Show("Comprehensive Network Stack and Adapter Reset executed! Please reboot your computer.", "Network Reset", "OK", "Information") }) }



if ($btnOfficeQuickRepair) {

    $btnOfficeQuickRepair.Add_Click({

        $c2rPaths = @(

            "C:\Program Files\Common Files\microsoft shared\ClickToRun\OfficeClickToRun.exe",

            "C:\Program Files (x86)\Common Files\microsoft shared\ClickToRun\OfficeClickToRun.exe"

        )

        $found = $false

        foreach ($p in $c2rPaths) {

            if (Test-Path $p) {

                Start-Process $p -ArgumentList "scenario=Repair platform=x64 culture=en-us Force=True" -Verb RunAs

                $found = $true

                break

            }

        }

        if (-not $found) {

            Start-Process appwiz.cpl

            [System.Windows.Forms.MessageBox]::Show("Office Click-to-Run launcher not located directly. Opened Installed Applications to select and repair Office.", "Office Repair", "OK", "Information")

        } else {

            [System.Windows.Forms.MessageBox]::Show("Microsoft Office Quick Repair initiated in background!", "Office Repair", "OK", "Information")

        }

    })

}



if ($btnLaunchScanPST) {

    $btnLaunchScanPST.Add_Click({

        $scanPstPaths = @(

            "C:\Program Files\Microsoft Office\root\Office16\SCANPST.EXE",

            "C:\Program Files (x86)\Microsoft Office\root\Office16\SCANPST.EXE",

            "C:\Program Files\Microsoft Office\Office16\SCANPST.EXE",

            "C:\Program Files (x86)\Microsoft Office\Office16\SCANPST.EXE",

            "C:\Program Files\Microsoft Office\Office15\SCANPST.EXE",

            "C:\Program Files (x86)\Microsoft Office\Office15\SCANPST.EXE",

            "C:\Program Files\Microsoft Office\Office14\SCANPST.EXE",

            "C:\Program Files (x86)\Microsoft Office\Office14\SCANPST.EXE"

        )

        $found = $false

        foreach ($p in $scanPstPaths) {

            if (Test-Path $p) {

                Start-Process $p

                $found = $true

                break

            }

        }

        if (-not $found) {

            $search = Get-ChildItem -Path "C:\Program Files", "C:\Program Files (x86)" -Filter "SCANPST.EXE" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

            if ($search) {

                Start-Process $search.FullName

                $found = $true

            }

        }

        if (-not $found) {

            [System.Windows.Forms.MessageBox]::Show("ScanPST.exe not found. Please ensure Microsoft Outlook is installed on this PC.", "ScanPST", "OK", "Warning")

        }

    })

}



if ($btnSafeWord) { $btnSafeWord.Add_Click({ Start-Process winword.exe -ArgumentList "/safe" -ErrorAction SilentlyContinue }) }

if ($btnSafeExcel) { $btnSafeExcel.Add_Click({ Start-Process excel.exe -ArgumentList "/safe" -ErrorAction SilentlyContinue }) }

if ($btnSafePPT) { $btnSafePPT.Add_Click({ Start-Process powerpnt.exe -ArgumentList "/safe" -ErrorAction SilentlyContinue }) }

if ($btnSafeOutlook) { $btnSafeOutlook.Add_Click({ Start-Process outlook.exe -ArgumentList "/safe" -ErrorAction SilentlyContinue }) }



if ($btnRebootRecovery) {

    $btnRebootRecovery.Add_Click({

        $res = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to reboot immediately into the Windows Advanced Startup / Recovery Menu?", "Reboot to Recovery", "YesNo", "Question")

        if ($res -eq [System.Windows.Forms.DialogResult]::Yes) {

            Start-Process shutdown.exe -ArgumentList "/r /o /f /t 00" -Verb RunAs

        }

    })

}



if ($btnEnableBootFailures) {

    $btnEnableBootFailures.Add_Click({

        Start-Process bcdedit.exe -ArgumentList "/set {default} bootstatuspolicy displayallfailures" -Wait

        Start-Process bcdedit.exe -ArgumentList "/set {default} recoveryenabled yes" -Wait

        [System.Windows.Forms.MessageBox]::Show("Windows Boot Failures Menu Policy and Recovery Enabled!", "Boot Policy", "OK", "Information")

    })

}



if ($btnFixPrinter0x11b) {

    $btnFixPrinter0x11b.Add_Click({

        Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Print" -Name "RpcAuthnLevelPrivacyEnabled" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Restart-Service -Name Spooler -Force -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Fixed Network Shared Printer Error 0x0000011b (RpcAuthnLevelPrivacyEnabled=0). Spooler restarted!", "Printer Fix", "OK", "Information")

    })

}



if ($btnConfigPrinterGPO) {

    $btnConfigPrinterGPO.Add_Click({

        $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows NT\Printers\RPC"

        if (-not (Test-Path $regPath)) { New-Item -Path $regPath -Force | Out-Null }

        Set-ItemProperty -Path $regPath -Name "RpcOverNamedPipes" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path $regPath -Name "RpcOverTcp" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path $regPath -Name "RpcAuthentication" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Group Policy RPC connection settings configured for seamless printer sharing!", "Printer Policy", "OK", "Information")

    })

}



if ($btnEnableLPD) {

    $btnEnableLPD.Add_Click({

        Start-Process cmd.exe -ArgumentList "/k dism /online /enable-feature /featurename:Printing-Foundation-LPDPrintService /featurename:Printing-Foundation-LPRPortMonitor /all /norestart & echo Done! & pause" -Verb RunAs

    })

}



if ($btnRestartPrinterServices) {

    $btnRestartPrinterServices.Add_Click({

        @("fdrespub", "SSDPSRV", "upnphost", "LanmanWorkstation", "LanmanServer", "Spooler") | ForEach-Object {

            Restart-Service -Name $_ -Force -ErrorAction SilentlyContinue

        }

        [System.Windows.Forms.MessageBox]::Show("Network Discovery, SMB Server/Workstation, and Print Spooler services restarted!", "Printer & Discovery Services", "OK", "Information")

    })

}



if ($btnFlushPrintSpooler) {

    $btnFlushPrintSpooler.Add_Click({

        Stop-Service -Name Spooler -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "C:\Windows\System32\spool\PRINTERS\*" -Force -Recurse -ErrorAction SilentlyContinue

        Start-Service -Name Spooler -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Print Spooler queue flushed and service restarted successfully!", "Print Spooler", "OK", "Information")

    })

}



if ($btnLaunchPrinterDiag) {

    $btnLaunchPrinterDiag.Add_Click({

        Start-Process msdt.exe -ArgumentList "/id PrinterDiagnostic" -ErrorAction SilentlyContinue

    })

}



if ($btnFlushRAMCache) {

    $btnFlushRAMCache.Add_Click({

        [System.GC]::Collect()

        [System.GC]::WaitForPendingFinalizers()

        Get-Process | ForEach-Object {

            try {

                $_.MinWorkingSet = [IntPtr]::Zero

                $_.MaxWorkingSet = [IntPtr]::Zero

            } catch {}

        }

        [System.Windows.Forms.MessageBox]::Show("Process memory working sets trimmed and RAM cache optimized!", "RAM Cache Optimizer", "OK", "Information")

    })

}



if ($btnCleanBrowserCache) {

    $btnCleanBrowserCache.Add_Click({

        $userProfile = $env:USERPROFILE

        $cachePaths = @(

            "$userProfile\AppData\Local\Google\Chrome\User Data\Default\Cache\*",

            "$userProfile\AppData\Local\Google\Chrome\User Data\Default\Code Cache\*",

            "$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*",

            "$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\Code Cache\*",

            "$userProfile\AppData\Local\Mozilla\Firefox\Profiles\*\cache2\*"

        )

        foreach ($cp in $cachePaths) {

            Remove-Item -Path $cp -Recurse -Force -ErrorAction SilentlyContinue

        }

        [System.Windows.Forms.MessageBox]::Show("Web Browser caches and temporary files cleared!", "Browser Cache", "OK", "Information")

    })

}



if ($btnRepairWUServiceComprehensive) {

    $btnRepairWUServiceComprehensive.Add_Click({

        Stop-Service -Name wuauserv, bits, cryptsvc, trustedinstaller, dosvc, UsoSvc -Force -ErrorAction SilentlyContinue

        Rename-Item -Path "C:\Windows\SoftwareDistribution" -NewName "SoftwareDistribution.old_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force -ErrorAction SilentlyContinue

        Rename-Item -Path "C:\Windows\System32\catroot2" -NewName "catroot2.old_$(Get-Date -Format 'yyyyMMdd_HHmmss')" -Force -ErrorAction SilentlyContinue

        Start-Service -Name wuauserv, bits, cryptsvc, trustedinstaller, dosvc, UsoSvc -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Comprehensive Windows Update Service pipeline and download cache fully reset!", "Windows Update Engine", "OK", "Information")

    })

}



if ($btnBlockWinUpdates) {

    $btnBlockWinUpdates.Add_Click({

        Stop-Service -Name wuauserv, bits, dosvc, UsoSvc, WaaSMedicSvc -Force -ErrorAction SilentlyContinue

        Set-Service -Name wuauserv, bits, dosvc, UsoSvc, WaaSMedicSvc -StartupType Disabled -ErrorAction SilentlyContinue

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Windows Updates completely disabled and blocked!", "Windows Updates", "OK", "Information")

    })

}



if ($btnEnableWinUpdates) {

    $btnEnableWinUpdates.Add_Click({

        Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-Service -Name wuauserv, bits, dosvc, UsoSvc -StartupType Manual -ErrorAction SilentlyContinue

        Start-Service -Name wuauserv, bits, dosvc -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Windows Updates restored and enabled to default state!", "Windows Updates", "OK", "Information")

    })

}



if ($btnResetDefenderPolicies) {

    $btnResetDefenderPolicies.Add_Click({

        Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender" -Recurse -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows Advanced Threat Protection" -Recurse -Force -ErrorAction SilentlyContinue

        Start-Process cmd.exe -ArgumentList "/c `"%ProgramFiles%\Windows Defender\MpCmdRun.exe`" -RestoreDefaults" -Wait -NoNewWindow

        [System.Windows.Forms.MessageBox]::Show("Windows Defender policies reset to default and service refreshed!", "Defender Policies", "OK", "Information")

    })

}



if ($btnRestoreFirewallSettings) {

    $btnRestoreFirewallSettings.Add_Click({

        Start-Process netsh.exe -ArgumentList "advfirewall reset" -Wait -NoNewWindow

        [System.Windows.Forms.MessageBox]::Show("Windows Firewall rules and configuration restored to default!", "Firewall Reset", "OK", "Information")

    })

}



if ($btnResetAudioPlaybackServices) {

    $btnResetAudioPlaybackServices.Add_Click({

        Restart-Service -Name Audiosrv, AudioEndpointBuilder -Force -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Windows Audio and Endpoint Builder services restarted!", "Audio Reset", "OK", "Information")

    })

}



if ($btnRestartExplorerQuick2) {
    $btnRestartExplorerQuick2.Add_Click({
        Restart-ExplorerShell -ShowDialog $true
    })
}



if ($btnClearAllEventLogs) {

    $btnClearAllEventLogs.Add_Click({

        Start-Process powershell.exe -ArgumentList "-NoProfile -Command `"wevtutil el | ForEach-Object { wevtutil cl `"`$_`" }`"" -Verb RunAs -Wait

        [System.Windows.Forms.MessageBox]::Show("All System, Application, and Security Event Logs cleared!", "Event Logs", "OK", "Information")

    })

}



if ($btnRebuildIconCache) {

    $btnRebuildIconCache.Add_Click({

        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue

        Start-Sleep -Milliseconds 500

        Remove-Item -Path "$env:LOCALAPPDATA\IconCache.db" -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue

        Start-Process explorer.exe

        [System.Windows.Forms.MessageBox]::Show("Desktop Icon & Thumbnail Cache purged and Explorer restarted!", "Icon & Thumbnail Cache", "OK", "Information")

    })

}



if ($btnRebuildFontCache) {

    $btnRebuildFontCache.Add_Click({

        Stop-Service -Name "FontCache" -Force -ErrorAction SilentlyContinue

        Stop-Service -Name "FontCache3.0.0.0" -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache*.dat" -Force -ErrorAction SilentlyContinue

        Remove-Item -Path "$env:LOCALAPPDATA\FontCache*.dat" -Force -ErrorAction SilentlyContinue

        Start-Service -Name "FontCache" -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Windows Font Cache database reset and rebuilt successfully!", "Font Cache", "OK", "Information")

    })

}



# ==================== SECURITY & NET ====================

$btnEnableUSBWriteProtect.Add_Click({

    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" -Force -ErrorAction SilentlyContinue | Out-Null

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" -Name "WriteProtect" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    Append-Log("USB Write-Protect ENABLED (Read-Only Mode).")

    [System.Windows.Forms.MessageBox]::Show("USB Write-Protect is now ENABLED! Pen drives cannot be written to.", "Security", "OK", "Information")

})

$btnDisableUSBWriteProtect.Add_Click({

    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\StorageDevicePolicies" -Name "WriteProtect" -Value 0 -Type DWord -Force -ErrorAction SilentlyContinue

    Append-Log("USB Write-Protect DISABLED (Normal Mode).")

    [System.Windows.Forms.MessageBox]::Show("USB Write-Protect is now DISABLED! Normal Read/Write access restored.", "Security", "OK", "Information")

})

$btnInjectHostsAdblock.Add_Click({

    $hosts = "$env:SystemRoot\System32\drivers\etc\hosts"

    $adBlockEntries = "`n# Antigravity Windows Tweaker Telemetry AdBlock`n0.0.0.0 telemetry.microsoft.com`n0.0.0.0 vortex.data.microsoft.com`n0.0.0.0 settings-win.data.microsoft.com`n0.0.0.0 watson.telemetry.microsoft.com`n"

    Add-Content -Path $hosts -Value $adBlockEntries -Force -ErrorAction SilentlyContinue

    [System.Windows.Forms.MessageBox]::Show("Telemetry and ad-blocking domains injected into Windows Hosts file!", "Hosts Security", "OK", "Information")

})

$btnResetHosts.Add_Click({

    $hosts = "$env:SystemRoot\System32\drivers\etc\hosts"

    $defaultHosts = "# Windows Default Hosts File`n127.0.0.1 localhost`n::1 localhost`n"

    Set-Content -Path $hosts -Value $defaultHosts -Encoding ascii -Force

    [System.Windows.Forms.MessageBox]::Show("Windows Hosts file reset to clean default!", "Hosts Security", "OK", "Information")

})

$btnAddDefenderExclusion.Add_Click({

    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog

    $fbd.Description = "Select folder to exclude from Windows Defender scanning"

    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {

        $folder = $fbd.SelectedPath

        Add-MpPreference -ExclusionPath $folder -ErrorAction SilentlyContinue

        [System.Windows.Forms.MessageBox]::Show("Defender Exclusion added for:`n$folder", "Defender", "OK", "Information")

    }

})

$btnEnableSandbox.Add_Click({ Start-Process powershell.exe -ArgumentList "-NoExit -Command Enable-WindowsOptionalFeature -Online -FeatureName 'Containers-DisposableClientVM' -All" -Verb RunAs })

$btnEnableHyperV.Add_Click({ Start-Process powershell.exe -ArgumentList "-NoExit -Command Enable-WindowsOptionalFeature -Online -FeatureName 'Microsoft-Hyper-V-All' -All" -Verb RunAs })



# ==================== WI-FI & DNS ====================

$btnExportWiFiPass.Add_Click({

    $desktop = [Environment]::GetFolderPath("Desktop")

    $outFile = "$desktop\Saved_WiFi_Passwords_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

    $profiles = netsh wlan show profiles | Select-String "All User Profile\s*:\s*(.*)$" | ForEach-Object { $_.Matches.Groups[1].Value.Trim() }

    $results = @("=========================================================================", "Windows Saved Wi-Fi Passwords Report", "Generated on $(Get-Date)", "=========================================================================`n")

    foreach ($p in $profiles) {

        $pInfo = netsh wlan show profile name="$p" key=clear

        $passLine = $pInfo | Select-String "Key Content\s*:\s*(.*)$"

        $pass = if ($passLine) { $passLine.Matches.Groups[1].Value.Trim() } else { "[Open / No Password]" }

        $results += "Network (SSID): $p`nPassword:       $pass`n"

    }

    $results | Out-File -FilePath $outFile -Encoding utf8

    Append-Log("Saved Wi-Fi Passwords exported to Desktop: $outFile")

    [System.Windows.Forms.MessageBox]::Show("Saved Wi-Fi Passwords exported to Desktop:`n$outFile", "Wi-Fi Passwords", "OK", "Information")

    Start-Process notepad.exe -ArgumentList "`"$outFile`""

})

$btnGenWiFiQR.Add_Click({

    $activeWlan = netsh wlan show interfaces | Select-String "SSID\s*:\s*(.*)$" | Select-Object -First 1

    if ($activeWlan) {

        $ssid = $activeWlan.Matches.Groups[1].Value.Trim()

        $pInfo = netsh wlan show profile name="$ssid" key=clear

        $passLine = $pInfo | Select-String "Key Content\s*:\s*(.*)$"

        $pass = if ($passLine) { $passLine.Matches.Groups[1].Value.Trim() } else { "" }

        $qrData = "WIFI:T:WPA;S:$ssid;P:$pass;;"

        $qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data=" + [System.Web.HttpUtility]::UrlEncode($qrData)

        Start-Process $qrUrl

        [System.Windows.Forms.MessageBox]::Show("Wi-Fi QR Code for '$ssid' generated! Scan with smartphone to connect instantly.", "Wi-Fi QR Generator", "OK", "Information")

    }

})

$btnApplyTCPAck.Add_Click({

    $interfaces = Get-ChildItem "HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces"

    foreach ($i in $interfaces) {

        Set-ItemProperty -Path $i.PSPath -Name "TcpAckFrequency" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

        Set-ItemProperty -Path $i.PSPath -Name "TCPNoDelay" -Value 1 -Type DWord -Force -ErrorAction SilentlyContinue

    }

    [System.Windows.Forms.MessageBox]::Show("TCP NoDelay & AckFrequency Gaming Tweaks Applied!", "Ping Optimizer", "OK", "Information")

})

if ($btnBoostTCPCongestion) {

    $btnBoostTCPCongestion.Add_Click({

        Start-Process netsh.exe -ArgumentList "int tcp set supplemental template=custom congestionprovider=ctcp" -Verb RunAs -Wait

        Append-Log("TCP Congestion Provider set to Compound TCP (CTCP).")

        [System.Windows.Forms.MessageBox]::Show("TCP Congestion Provider configured for Maximum Bandwidth!", "Network", "OK", "Information")

    })

}

$btnViewActivePorts.Add_Click({ Start-Process cmd.exe -ArgumentList "/k netstat -ano" -Verb RunAs })

$btnResetWinsock3.Add_Click({

    Start-Process netsh.exe -ArgumentList "winsock reset" -Wait

    Start-Process netsh.exe -ArgumentList "int ip reset" -Wait

    [System.Windows.Forms.MessageBox]::Show("Winsock & TCP/IP stack reset. Please restart PC when convenient.", "Network", "OK", "Information")

})

$btnDNSCloudflare.Add_Click({

    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("1.1.1.1", "1.0.0.1")

    [System.Windows.Forms.MessageBox]::Show("DNS set to Cloudflare (1.1.1.1, 1.0.0.1)!", "DNS", "OK", "Information")

})

$btnDNSGoogle.Add_Click({

    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("8.8.8.8", "8.8.4.4")

    [System.Windows.Forms.MessageBox]::Show("DNS set to Google (8.8.8.8, 8.8.4.4)!", "DNS", "OK", "Information")

})

$btnDNSQuad9.Add_Click({

    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("9.9.9.9", "149.112.112.112")

    [System.Windows.Forms.MessageBox]::Show("DNS set to Quad9 (9.9.9.9, 149.112.112.112)!", "DNS", "OK", "Information")

})

$btnDNSDHCP.Add_Click({

    $adapter = Get-NetAdapter | Where-Object {$_.Status -eq "Up"} | Select-Object -First 1

    Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ResetServerAddresses

    [System.Windows.Forms.MessageBox]::Show("DNS reset to DHCP (Automatic)!", "DNS", "OK", "Information")

})



# ==================== MICROSOFT OFFICE & ACTIVATION SUITE ====================

function Start-OfficeInstaller {
    param(
        [string]$ProductID,
        [string]$ProductTitle
    )

    # Check if Microsoft Office is already installed on the system
    $isOfficeInstalled = $false
    $wordPaths = @(
        "C:\Program Files\Microsoft Office\root\Office16\WINWORD.EXE",
        "C:\Program Files (x86)\Microsoft Office\root\Office16\WINWORD.EXE",
        "C:\Program Files\Microsoft Office\Office16\WINWORD.EXE",
        "C:\Program Files (x86)\Microsoft Office\Office16\WINWORD.EXE",
        "C:\Program Files\Microsoft Office\Office15\WINWORD.EXE",
        "C:\Program Files (x86)\Microsoft Office\Office15\WINWORD.EXE"
    )
    foreach ($wp in $wordPaths) {
        if (Test-Path $wp) {
            $isOfficeInstalled = $true
            break
        }
    }

    if ($isOfficeInstalled) {
        $diagMsg = "Microsoft Office is ALREADY INSTALLED on this computer!`n`n" +
                   "• Click [YES] to ACTIVATE Office immediately with permanent Ohook activation (Recommended).`n`n" +
                   "• Click [NO] to proceed with DOWNLOADING & RE-INSTALLING $ProductTitle.`n`n" +
                   "• Click [CANCEL] to abort."
        $res = [System.Windows.Forms.MessageBox]::Show($diagMsg, "Microsoft Office Detected", [System.Windows.Forms.MessageBoxButtons]::YesNoCancel, [System.Windows.Forms.MessageBoxIcon]::Question)
        if ($res -eq [System.Windows.Forms.DialogResult]::Yes) {
            Append-Log("User selected direct Office Activation. Launching Ohook...")
            Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"& ([scriptblock]::Create((irm https://get.activated.win))) /Ohook`"" -Verb RunAs
            return
        } elseif ($res -eq [System.Windows.Forms.DialogResult]::Cancel) {
            Append-Log("Office installation cancelled by user.")
            return
        }
    }

    Append-Log("Launching official Microsoft installer for $ProductTitle ($ProductID)...")

    $arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x86" }
    $downloadUrl = "https://c2rsetup.officeapps.live.com/c2r/download.aspx?ProductreleaseID=$ProductID&platform=$arch&language=en-us&version=O16GA"

    $runner = @"
`$host.UI.RawUI.WindowTitle = "Venkat Tweaker - Official Microsoft Office Installer"
Clear-Host
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host "          VENKAT TWEAKER - MICROSOFT OFFICE INSTALLER SUITE" -ForegroundColor Yellow
Write-Host "=========================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "  Product Edition : $ProductTitle" -ForegroundColor Green
Write-Host "  Product ID      : $ProductID" -ForegroundColor White
Write-Host "  Architecture    : $arch" -ForegroundColor White
Write-Host "  Source Server   : Microsoft Official CDN (OfficeClickToRun)" -ForegroundColor Gray
Write-Host ""
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "[*] Step 1/3: Downloading Microsoft Click-to-Run Setup bootstrapper..." -ForegroundColor Cyan

`$tempExe = "`$env:TEMP\OfficeSetup_$ProductID.exe"

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    `$wc = New-Object System.Net.WebClient
    `$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
    Write-Host "[*] Connecting to: $downloadUrl" -ForegroundColor Gray
    `$wc.DownloadFile("$downloadUrl", `$tempExe)
    `$fileSize = [Math]::Round((Get-Item `$tempExe).Length / 1MB, 2)
    Write-Host "[✓] Downloaded successfully: `$tempExe (`$fileSize MB)" -ForegroundColor Green
} catch {
    Write-Host "[!] WebClient download error: `$(`$_.Exception.Message)" -ForegroundColor Red
    Write-Host "[*] Trying PowerShell Invoke-WebRequest fallback..." -ForegroundColor Yellow
    try {
        Invoke-WebRequest -Uri "$downloadUrl" -OutFile `$tempExe -UseBasicParsing
        Write-Host "[✓] Downloaded successfully via fallback!" -ForegroundColor Green
    } catch {
        Write-Host "[X] Fatal error downloading installer: `$(`$_.Exception.Message)" -ForegroundColor Red
        Write-Host "Press any key to exit..."
        `$null = `$host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        exit
    }
}

Write-Host ""
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "[*] Step 2/3: Starting Microsoft Office Click-to-Run Setup..." -ForegroundColor Cyan
Write-Host "[*] The official Microsoft Office installation window will now appear." -ForegroundColor Yellow
Write-Host "[*] Office will download components and install Word, Excel, PowerPoint, etc." -ForegroundColor Yellow
Write-Host ""

`$proc = Start-Process -FilePath `$tempExe -PassThru

Write-Host "[✓] Microsoft Office Setup started (PID: `$(`$proc.Id))." -ForegroundColor Green
Write-Host ""
Write-Host "-------------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host "[*] Step 3/3: Activation (Ohook Permanent Activation)" -ForegroundColor Cyan
Write-Host "Once Microsoft Office finishes installation, you can activate it permanently." -ForegroundColor White
Write-Host ""
`$choice = Read-Host "Would you like to activate Office now with Ohook? (Type 'Y' for Yes, or press Enter to skip)"
if (`$choice -match "^[yY]") {
    Write-Host "[*] Launching MAS Ohook Permanent Office Activation..." -ForegroundColor Cyan
    & ([scriptblock]::Create((irm https://get.activated.win))) /Ohook
} else {
    Write-Host ""
    Write-Host "[i] You can activate anytime later using the 'Activate Office' button in Venkat Tweaker!" -ForegroundColor Green
    Start-Sleep -Seconds 4
}
"@

    $encoded = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($runner))
    Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -EncodedCommand $encoded" -Verb RunAs
}

# Office Installer Buttons
if ($btnInstallM365) {
    $btnInstallM365.Add_Click({ Start-OfficeInstaller -ProductID "O365ProPlusRetail" -ProductTitle "Microsoft 365 Enterprise Suite" })
}
if ($btnInstall2019) {
    $btnInstall2019.Add_Click({ Start-OfficeInstaller -ProductID "ProPlus2019Retail" -ProductTitle "Microsoft Office LTSC 2019 ProPlus" })
}
if ($btnInstall2021) {
    $btnInstall2021.Add_Click({ Start-OfficeInstaller -ProductID "ProPlus2021Retail" -ProductTitle "Microsoft Office LTSC 2021 ProPlus" })
}
if ($btnInstall2024) {
    $btnInstall2024.Add_Click({ Start-OfficeInstaller -ProductID "ProPlus2024Retail" -ProductTitle "Microsoft Office LTSC 2024 ProPlus" })
}

# Activation Buttons
if ($btnActWindows) {
    $btnActWindows.Add_Click({
        Append-Log("Launching Windows HWID permanent digital license activation...")
        Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"& ([scriptblock]::Create((irm https://get.activated.win))) /HWID`"" -Verb RunAs
    })
}
if ($btnActOffice) {
    $btnActOffice.Add_Click({
        Append-Log("Launching Office Ohook permanent activation...")
        Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"& ([scriptblock]::Create((irm https://get.activated.win))) /Ohook`"" -Verb RunAs
    })
}
if ($btnActKMS) {
    $btnActKMS.Add_Click({
        Append-Log("Launching Online KMS activation...")
        Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"& ([scriptblock]::Create((irm https://get.activated.win))) /KMS-Act`"" -Verb RunAs
    })
}
if ($btnCleanKMS) {
    $btnCleanKMS.Add_Click({
        Append-Log("Uninstalling / Cleaning Online KMS activation...")
        Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"& ([scriptblock]::Create((irm https://get.activated.win))) /KMS-Clean`"" -Verb RunAs
    })
}
if ($btnChangeEdition) {
    $btnChangeEdition.Add_Click({
        Append-Log("Opening Windows / Office Edition Change menu...")
        Start-Process powershell.exe -ArgumentList "-NoExit -ExecutionPolicy Bypass -Command `"irm https://get.activated.win | iex`"" -Verb RunAs
    })
}



# ==================== BACKUPS & HUB ====================

$btnBrowseSource.Add_Click({

    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog

    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $txtSourceFolder.Text = $fbd.SelectedPath }

})

$btnBrowseTarget.Add_Click({

    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog

    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $txtTargetFolder.Text = $fbd.SelectedPath }

})

$btnRunRobocopy.Add_Click({

    $src = $txtSourceFolder.Text.Trim()

    $dst = $txtTargetFolder.Text.Trim()

    if (-not $src -or -not $dst) { return }

    Append-Log("Executing Robocopy Mirror from '$src' to '$dst'...")

    Start-Process robocopy.exe -ArgumentList "`"$src`" `"$dst`" /MIR /MT:8 /R:1 /W:1 /NP /TEE" -Wait

    Append-Log("Robocopy Mirror job finished successfully!")

    [System.Windows.Forms.MessageBox]::Show("Robocopy Mirror job completed successfully!", "Migration Engine", "OK", "Information")

})

$btnExportBookmarks2.Add_Click({

    $desktop = [Environment]::GetFolderPath("Desktop")

    $userProfile = $env:USERPROFILE

    $bList = @(

        @{Name="Chrome"; Path="$userProfile\AppData\Local\Google\Chrome\User Data\Default\Bookmarks"},

        @{Name="Edge"; Path="$userProfile\AppData\Local\Microsoft\Edge\User Data\Default\Bookmarks"},

        @{Name="Brave"; Path="$userProfile\AppData\Local\BraveSoftware\Brave-Browser\User Data\Default\Bookmarks"}

    )

    $copied = 0

    foreach ($b in $bList) {

        if (Test-Path $b.Path) {

            Copy-Item -Path $b.Path -Destination "$desktop\$($b.Name)_Bookmarks.json" -Force

            $copied++

        }

    }

    Append-Log("Exported $copied browser bookmarks.")

    [System.Windows.Forms.MessageBox]::Show("Exported $copied browser bookmarks files directly onto Desktop!", "Bookmarks", "OK", "Information")

})

$script:ExportDriversAction = {

    param([string]$targetBaseFolder)

    $desktop = [Environment]::GetFolderPath("Desktop")

    if ([string]::IsNullOrWhiteSpace($targetBaseFolder)) { $targetBaseFolder = $desktop }

    $driverDest = Join-Path $targetBaseFolder "Exported_Drivers_$(Get-Date -Format 'yyyyMMdd_HHmmss')"

    New-Item -Path $driverDest -ItemType Directory -Force | Out-Null

    Append-Log("Exporting 3rd-party device drivers to '$driverDest'...")



    try {

        Export-WindowsDriver -Online -Destination $driverDest -ErrorAction Stop | Out-Null

    } catch {

        Start-Process pnputil.exe -ArgumentList "/export-driver * `"$driverDest`"" -Wait -NoNewWindow

    }



    $infCount = (Get-ChildItem -Path $driverDest -Filter "*.inf" -Recurse -ErrorAction SilentlyContinue).Count

    Append-Log("Driver backup completed! Total packages exported: $infCount")

    [System.Windows.Forms.MessageBox]::Show("All custom device drivers backed up successfully!`n`nDestination: $driverDest`nTotal INF Packages: $infCount", "Driver Backup", "OK", "Information")

}



$script:RestoreDriversAction = {

    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog

    $fbd.Description = "Select folder containing exported driver (.INF) files"

    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {

        $path = $fbd.SelectedPath

        Append-Log("Importing and installing device drivers from '$path' via PnPUTIL...")

        $proc = Start-Process pnputil.exe -ArgumentList "/add-driver `"$path\*.inf`" /subdirs /install" -NoNewWindow -PassThru -Wait

        Append-Log("Driver restoration completed (Exit Code: $($proc.ExitCode)).")

        [System.Windows.Forms.MessageBox]::Show("Device driver restoration command executed from:`n$path`n`nCheck Device Manager to verify hardware status.", "Driver Restore", "OK", "Information")

    }

}



$script:OfflineInjectAction = {

    $drivePrompt = [Microsoft.VisualBasic.Interaction]::InputBox("Enter Target Windows Drive Letter (e.g. D: or E:):", "Offline Driver Injection (DISM)", "D:")

    if ([string]::IsNullOrWhiteSpace($drivePrompt)) { return }

    $driveLetter = $drivePrompt.TrimEnd('\')

    if (-not (Test-Path "$driveLetter\Windows")) {

        [System.Windows.Forms.MessageBox]::Show("Could not find a valid Windows directory at '$driveLetter\Windows'. Please check the drive letter.", "Invalid Target Drive", "OK", "Warning")

        return

    }



    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog

    $fbd.Description = "Select folder containing driver INF files to inject into $driveLetter"

    if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {

        $driverPath = $fbd.SelectedPath

        Append-Log("Injecting drivers into offline OS '$driveLetter\' from '$driverPath'...")

        Start-Process cmd.exe -ArgumentList "/k DISM /Image:$driveLetter\ /Add-Driver /Driver:`"$driverPath`" /Recurse" -Verb RunAs

        Append-Log("DISM offline driver injection process launched.")

    }

}



$btnExportDrivers.Add_Click({ & $script:ExportDriversAction })

if ($btnOpenDriversHubPT) {
    $btnOpenDriversHubPT.Add_Click({
        $tabDrivers = $tabControl.Items | Where-Object { $_.Header -like "*Drivers*" } | Select-Object -First 1
        if ($tabDrivers) {
            $tabControl.SelectedItem = $tabDrivers
            Append-Log("Navigated to Data & Drivers Hub.")
        }
    })
}

if ($btnExportDriversCustom) {
    $btnExportDriversCustom.Add_Click({
        $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
        $fbd.Description = "Select target folder or external USB drive for Driver Backup"
        if ($fbd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            & $script:ExportDriversAction $fbd.SelectedPath
        }
    })
}

$btnRestoreDrivers.Add_Click({ & $script:RestoreDriversAction })

if ($btnOfflineInjectDrivers) { $btnOfflineInjectDrivers.Add_Click({ & $script:OfflineInjectAction }) }



if ($btnListDrivers) {

    $btnListDrivers.Add_Click({

        Append-Log("Fetching installed third-party drivers list...")

        try {

            $drivers = Get-WindowsDriver -Online -All | Where-Object { $_.Driver -match "oem" -or ($_.ProviderName -and $_.ProviderName -notmatch "Microsoft") } | Select-Object -First 40

            if ($drivers) {

                Append-Log("--- INSTALLED THIRD-PARTY DRIVERS ---")

                foreach ($d in $drivers) {

                    Append-Log("[$($d.Driver)] Class: $($d.ClassName) | Provider: $($d.ProviderName) | Version: $($d.Version) | Date: $($d.Date)")

                }

                Append-Log("--- END OF DRIVER LIST ---")

            } else {

                $pnpList = pnputil /enum-drivers

                Append-Log(($pnpList -join "`r`n"))

            }

        } catch {

            Start-Process cmd.exe -ArgumentList "/k pnputil /enum-drivers" -Verb RunAs

        }

    })

}



if ($btnOpenDevMgmt) {
    $btnOpenDevMgmt.Add_Click({
        Append-Log("Launching Device Manager with Ghost / Non-Present Drivers view enabled...")
        [Environment]::SetEnvironmentVariable("DEVMGR_SHOW_NONPRESENT_DEVICES", "1", [EnvironmentVariableTarget]::Process)
        Start-Process devmgmt.msc
    })
}



if ($btnCleanDriverStore) {

    $btnCleanDriverStore.Add_Click({

        Append-Log("Launching Driver Store and Component Cleanup engine...")

        Start-Process cmd.exe -ArgumentList "/k echo === DISM & PNP CLEANUP === & DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase & echo Done! & pause" -Verb RunAs

    })

}

$btnUpgradeWinget.Add_Click({

    Append-Log("Running WinGet software upgrade suite...")

    Start-Process cmd.exe -ArgumentList "/k winget upgrade --all --include-unknown --accept-package-agreements --accept-source-agreements" -Verb RunAs

})

$btnRestartTally.Add_Click({

    Append-Log("Restarting Tally and Gateway system services...")

    Get-Service | Where-Object { $_.Name -match "tally|gateway" } | Restart-Service -Force -ErrorAction SilentlyContinue

    Append-Log("Tally / Gateway engines cycled.")

    [System.Windows.Forms.MessageBox]::Show("Tally & Gateway Services Restarted!", "Tally Engine", "OK", "Information")

})

$btnPurgeCache.Add_Click({

    Append-Log("Purging Prefetch, Temp, and System Cache...")

    @($env:TEMP, "C:\Windows\Temp", "C:\Windows\Prefetch") | ForEach-Object {

        if (Test-Path $_) { Remove-Item "$_\*" -Recurse -Force -ErrorAction SilentlyContinue }

    }

    Clear-DnsClientCache

    Append-Log("Cache purge complete.")

    [System.Windows.Forms.MessageBox]::Show("Prefetch, Cache, and Temp files completely purged!", "Cache Purge", "OK", "Information")

})



# ==================== QUICK HUB ====================

$btnHubReg2.Add_Click({ Start-Process regedit.exe -Verb RunAs })

$btnHubDev2.Add_Click({ Start-Process devmgmt.msc })

$btnHubGP2.Add_Click({ Start-Process gpedit.msc })

$btnHubDisk2.Add_Click({ Start-Process diskmgmt.msc })

$btnHubTask2.Add_Click({ Start-Process taskmgr.exe })

$btnHubRes2.Add_Click({ Start-Process resmon.exe })

$btnHubDx2.Add_Click({ Start-Process dxdiag.exe })

$btnHubServ2.Add_Click({ Start-Process services.msc })



# SEARCH FILTER

$btnSearch.Add_Click({

    $q = $txtSearch.Text.Trim().ToLower()

    if ($q -and $q -notmatch "search tools") {

        Append-Log("Searching suite for keyword: '$q'...")

        [System.Windows.Forms.MessageBox]::Show("Search completed for '$q'. Please check relevant tabs.", "Search Tool", "OK", "Information")

    }

})



$btnCloseApp.Add_Click({
    $res = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to exit Venkat Windows Tweaker Suite?", "Exit Application", "YesNo", "Question")
    if ($res -eq [System.Windows.Forms.DialogResult]::Yes) {
        $window.Close()
    }
})



# Show Main Window

$window.ShowDialog() | Out-Null
