# Build script for WindowsTweaker.exe Native Launcher
$ErrorActionPreference = "Stop"

$currentDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $currentDir) { $currentDir = Get-Location }

$cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
$iconPath = Join-Path $currentDir "tweaker_icon.ico"
$outputExe = Join-Path $currentDir "WindowsTweaker.exe"

$csSource = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Net;
using System.Security.Principal;
using System.Windows.Forms;

namespace VenkatWindowsTweaker
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                if (!IsAdministrator())
                {
                    // Relaunch self as Administrator
                    ProcessStartInfo proc = new ProcessStartInfo();
                    proc.UseShellExecute = true;
                    proc.WorkingDirectory = Environment.CurrentDirectory;
                    proc.FileName = Application.ExecutablePath;
                    proc.Verb = "runas";
                    try
                    {
                        Process.Start(proc);
                    }
                    catch
                    {
                        MessageBox.Show("Administrator privileges are required to run Venkat Windows Tweaker Suite.", "Permission Denied", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                    return;
                }

                string appDir = AppDomain.CurrentDomain.BaseDirectory;
                string scriptPath = Path.Combine(appDir, "WindowsTweaker.ps1");

                // If local script does not exist, download to temp or run from web
                if (!File.Exists(scriptPath))
                {
                    string tempScript = Path.Combine(Path.GetTempPath(), "WindowsTweaker.ps1");
                    try
                    {
                        ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12 | SecurityProtocolType.Tls11 | SecurityProtocolType.Tls;
                        using (WebClient wc = new WebClient())
                        {
                            wc.Headers.Add("user-agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)");
                            wc.DownloadFile("https://raw.githubusercontent.com/venkat-tools/Venkat-Windows-Tweaker-Suite/main/WindowsTweaker.ps1", tempScript);
                        }
                        scriptPath = tempScript;
                    }
                    catch (Exception ex)
                    {
                        MessageBox.Show("Could not find local WindowsTweaker.ps1 or download the latest version online.\n\nError: " + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
                        return;
                    }
                }

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "powershell.exe";
                psi.Arguments = string.Format("-ExecutionPolicy Bypass -NoProfile -WindowStyle Hidden -File \"{0}\"", scriptPath);
                psi.UseShellExecute = false;
                psi.CreateNoWindow = true;
                psi.WorkingDirectory = appDir;

                Process.Start(psi);
            }
            catch (Exception ex)
            {
                MessageBox.Show("Unexpected error starting Windows Tweaker:\n" + ex.Message, "Error", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
        }

        private static bool IsAdministrator()
        {
            WindowsIdentity identity = WindowsIdentity.GetCurrent();
            WindowsPrincipal principal = new WindowsPrincipal(identity);
            return principal.IsInRole(WindowsBuiltInRole.Administrator);
        }
    }
}
"@

$sourceFile = Join-Path $currentDir "Launcher.cs"
Set-Content -Path $sourceFile -Value $csSource -Encoding UTF8

$compileArgs = @(
    "/target:winexe",
    "/optimize+",
    "/platform:anycpu",
    "/r:System.dll",
    "/r:System.Windows.Forms.dll",
    "/r:System.Drawing.dll",
    "/out:`"$outputExe`"",
    "`"$sourceFile`""
)

if (Test-Path $iconPath) {
    $compileArgs = @("/win32icon:`"$iconPath`"") + $compileArgs
}

Write-Host "Compiling WindowsTweaker.exe..."
$proc = Start-Process -FilePath $cscPath -ArgumentList $compileArgs -Wait -NoNewWindow -PassThru

if ($proc.ExitCode -eq 0 -and (Test-Path $outputExe)) {
    Write-Host "SUCCESS: $outputExe built successfully!" -ForegroundColor Green
    Remove-Item $sourceFile -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "FAILED: Compilation returned exit code $($proc.ExitCode)" -ForegroundColor Red
}
