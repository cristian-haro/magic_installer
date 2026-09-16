# ==============================================================================
# Magic Installer - Win32 Icon Generator (.ico)
# ==============================================================================

Add-Type -AssemblyName System.Drawing

$rootDir = (Get-Item $PSScriptRoot).Parent.FullName
$assetsDir = Join-Path $rootDir "assets"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}
$outputPath = Join-Path $assetsDir "icon.ico"

$sz = 256
$bmp = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

$margin = [Math]::Max(1.0, $sz * 0.02)
$rect = New-Object System.Drawing.RectangleF($margin, $margin, ($sz - (2.0 * $margin)), ($sz - (2.0 * $margin)))
$cornerRad = [Math]::Max(3.0, ($sz * 0.22))
$d = $cornerRad * 2.0

$path = New-Object System.Drawing.Drawing2D.GraphicsPath
$path.AddArc($rect.X, $rect.Y, $d, $d, 180.0, 90.0)
$path.AddArc(($rect.Right - $d), $rect.Y, $d, $d, 270.0, 90.0)
$path.AddArc(($rect.Right - $d), ($rect.Bottom - $d), $d, $d, 0.0, 90.0)
$path.AddArc($rect.X, ($rect.Bottom - $d), $d, $d, 90.0, 90.0)
$path.CloseFigure()

$pt1 = New-Object System.Drawing.PointF($rect.X, $rect.Y)
$pt2 = New-Object System.Drawing.PointF($rect.Right, $rect.Bottom)
$c1 = [System.Drawing.Color]::FromArgb(255, 15, 23, 42)
$c2 = [System.Drawing.Color]::FromArgb(255, 37, 99, 235)
$brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($pt1, $pt2, $c1, $c2)
$g.FillPath($brush, $path)

$penColor = [System.Drawing.Color]::FromArgb(200, 56, 189, 248)
$penWidth = [Math]::Max(1.0, ($sz * 0.035))
$pen = New-Object System.Drawing.Pen($penColor, $penWidth)
$g.DrawPath($pen, $path)

$cx = [float]($sz / 2.0)
$cy = [float]($sz / 2.0)
$rOut = [float]($sz * 0.32)
$rIn = [float]($sz * 0.09)

$starPath = New-Object System.Drawing.Drawing2D.GraphicsPath
[System.Drawing.PointF[]]$points = @(
    (New-Object System.Drawing.PointF($cx, ($cy - $rOut))),
    (New-Object System.Drawing.PointF(($cx + $rIn), ($cy - $rIn))),
    (New-Object System.Drawing.PointF(($cx + $rOut), $cy)),
    (New-Object System.Drawing.PointF(($cx + $rIn), ($cy + $rIn))),
    (New-Object System.Drawing.PointF($cx, ($cy + $rOut))),
    (New-Object System.Drawing.PointF(($cx - $rIn), ($cy + $rIn))),
    (New-Object System.Drawing.PointF(($cx - $rOut), $cy)),
    (New-Object System.Drawing.PointF(($cx - $rIn), ($cy - $rIn)))
)
$starPath.AddPolygon($points)

$spt1 = New-Object System.Drawing.PointF($cx, ($cy - $rOut))
$spt2 = New-Object System.Drawing.PointF($cx, ($cy + $rOut))
$sc1 = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
$sc2 = [System.Drawing.Color]::FromArgb(255, 125, 211, 252)
$starBrush = New-Object System.Drawing.Drawing2D.LinearGradientBrush($spt1, $spt2, $sc1, $sc2)
$g.FillPath($starBrush, $starPath)

$sx = [float]($cx + ($sz * 0.22))
$sy = [float]($cy - ($sz * 0.22))
$srOut = [float]($sz * 0.12)
$srIn = [float]($sz * 0.035)

$spPath = New-Object System.Drawing.Drawing2D.GraphicsPath
[System.Drawing.PointF[]]$spPoints = @(
    (New-Object System.Drawing.PointF($sx, ($sy - $srOut))),
    (New-Object System.Drawing.PointF(($sx + $srIn), ($sy - $srIn))),
    (New-Object System.Drawing.PointF(($sx + $srOut), $sy)),
    (New-Object System.Drawing.PointF(($sx + $srIn), ($sy + $srIn))),
    (New-Object System.Drawing.PointF($sx, ($sy + $srOut))),
    (New-Object System.Drawing.PointF(($sx - $srIn), ($sy + $srIn))),
    (New-Object System.Drawing.PointF(($sx - $srOut), $sy)),
    (New-Object System.Drawing.PointF(($sx - $srIn), ($sy - $srIn)))
)
$spPath.AddPolygon($spPoints)
$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(245, 255, 255, 255))
$g.FillPath($whiteBrush, $spPath)
$g.Dispose()

$hIcon = $bmp.GetHicon()
$icon = [System.Drawing.Icon]::FromHandle($hIcon)
$fs = [System.IO.File]::Create($outputPath)
$icon.Save($fs)
$fs.Close()
$icon.Dispose()
$bmp.Dispose()

Write-Host "[OK] Icono generado con exito en: $outputPath" -ForegroundColor Green
