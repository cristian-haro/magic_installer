# ==============================================================================
# Magic Installer - Build Script to standalone .exe using native .NET C# compiler
# ==============================================================================

$ErrorActionPreference = "Stop"

$buildDir = $PSScriptRoot
if (-not $buildDir) { $buildDir = (Get-Location).Path }
$rootDir = (Get-Item $buildDir).Parent.FullName

$ps1Path = Join-Path $rootDir "src\Magic_Installer.ps1"
$exePath = Join-Path $rootDir "Magic_Installer.exe"
$manifestPath = Join-Path $buildDir "app.manifest"

Write-Host "Iniciando compilacion de Magic Installer..." -ForegroundColor Cyan

# 1. Comprobar que el script fuente existe
if (-not (Test-Path $ps1Path)) {
    Write-Error "No se encontro Magic_Installer.ps1 en $ps1Path"
    Exit 1
}

# 2. Localizar compilador csc.exe de .NET Framework 4.x
$cscPath = "$env:SystemRoot\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $cscPath)) {
    $cscPath = "$env:SystemRoot\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

if (-not (Test-Path $cscPath)) {
    Write-Error "No se encontro el compilador csc.exe en el sistema."
    Exit 1
}

# 3. Crear Manifiesto de Administrador para solicitar UAC nativamente
$manifestContent = @"
<?xml version="1.0" encoding="utf-8"?>
<assembly manifestVersion="1.0" xmlns="urn:schemas-microsoft-com:asm.v1">
  <assemblyIdentity version="1.0.0.0" name="MagicInstaller.App"/>
  <trustInfo xmlns="urn:schemas-microsoft-com:asm.v2">
    <security>
      <requestedPrivileges xmlns="urn:schemas-microsoft-com:asm.v3">
        <requestedExecutionLevel level="requireAdministrator" uiAccess="false" />
      </requestedPrivileges>
    </security>
  </trustInfo>
  <compatibility xmlns="urn:schemas-microsoft-com:compatibility.v1">
    <application>
      <!-- Windows 10 & 11 -->
      <supportedOS Id="{8e0f7a12-bfb3-4fe8-b9a5-48fd50a15a9a}" />
    </application>
  </compatibility>
</assembly>
"@
Set-Content -Path $manifestPath -Value $manifestContent -Encoding UTF8

# 4. Codificar el script de PowerShell en Base64
$psContent = Get-Content -Path $ps1Path -Raw -Encoding UTF8
$bytes = [System.Text.Encoding]::UTF8.GetBytes($psContent)
$base64Script = [System.Convert]::ToBase64String($bytes)

# 5. Generar codigo fuente C# del Launcher Wrapper
$csSource = @"
using System;
using System.Diagnostics;
using System.IO;
using System.Text;

namespace MagicInstaller
{
    static class Program
    {
        [STAThread]
        static void Main(string[] args)
        {
            try
            {
                string encodedScript = "$base64Script";
                byte[] data = Convert.FromBase64String(encodedScript);
                string decodedScript = Encoding.UTF8.GetString(data);

                string tempDir = Path.Combine(Path.GetTempPath(), "MagicInstaller");
                if (!Directory.Exists(tempDir))
                {
                    Directory.CreateDirectory(tempDir);
                }

                string scriptFile = Path.Combine(tempDir, "run_installer.ps1");
                File.WriteAllText(scriptFile, decodedScript, Encoding.UTF8);

                ProcessStartInfo psi = new ProcessStartInfo();
                psi.FileName = "powershell.exe";
                psi.Arguments = "-NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File \"" + scriptFile + "\"";
                psi.WindowStyle = ProcessWindowStyle.Hidden;
                psi.CreateNoWindow = true;
                psi.UseShellExecute = true;

                Process proc = Process.Start(psi);
                if (proc != null)
                {
                    proc.WaitForExit();
                }

                try
                {
                    if (File.Exists(scriptFile))
                    {
                        File.Delete(scriptFile);
                    }
                }
                catch { }
            }
            catch (Exception ex)
            {
                System.Windows.Forms.MessageBox.Show("Error al ejecutar Magic Installer: " + ex.Message, "Magic Installer Error", System.Windows.Forms.MessageBoxButtons.OK, System.Windows.Forms.MessageBoxIcon.Error);
            }
        }
    }
}
"@

$tempCsPath = Join-Path $buildDir "launcher_temp.cs"
Set-Content -Path $tempCsPath -Value $csSource -Encoding UTF8

# 6. Comprobar o generar icono .ico
$iconPath = Join-Path $rootDir "assets\icon.ico"
if (-not (Test-Path $iconPath)) {
    $genIconScript = Join-Path $buildDir "generate_icon.ps1"
    if (Test-Path $genIconScript) {
        & $genIconScript | Out-Null
    }
}

# 7. Compilar a .exe con csc.exe
Write-Host "Compilando ejecutable standalone Magic_Installer.exe en la raiz..." -ForegroundColor Yellow
$cscArgs = @(
    "/target:winexe",
    "/optimize+",
    "/platform:anycpu",
    "/win32manifest:`"$manifestPath`"",
    "/out:`"$exePath`"",
    "/reference:System.Windows.Forms.dll",
    "/reference:System.dll"
)

if (Test-Path $iconPath) {
    $cscArgs += "/win32icon:`"$iconPath`""
}

$cscArgs += "`"$tempCsPath`""

$process = Start-Process -FilePath $cscPath -ArgumentList $cscArgs -NoNewWindow -PassThru -Wait

# Limpiar archivos temporales de compilacion
Remove-Item $tempCsPath, $manifestPath -Force -ErrorAction SilentlyContinue

if ($process.ExitCode -eq 0 -and (Test-Path $exePath)) {
    Write-Host "[OK] Compilacion completada con exito: $exePath" -ForegroundColor Green
} else {
    Write-Error "Fallo la compilacion con codigo $($process.ExitCode)"
}
