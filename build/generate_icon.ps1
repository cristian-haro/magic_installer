# ==============================================================================
# Magic Installer - Win32 Multi-Resolution Icon Generator (.ico)
# Extracts and centers the emblem from assets/logo.png for all Windows icon sizes
# ==============================================================================

Add-Type -AssemblyName System.Drawing

$rootDir = (Get-Item $PSScriptRoot).Parent.FullName
$assetsDir = Join-Path $rootDir "assets"
$logoPath = Join-Path $assetsDir "logo.png"
$outputPath = Join-Path $assetsDir "icon.ico"

if (-not (Test-Path $logoPath)) {
    Write-Error "No se encontro el archivo de logo en $logoPath"
    Exit 1
}

$srcBmp = [System.Drawing.Bitmap]::FromFile($logoPath)

# 1. Localizar los limites del isotipo/emblema central (zona superior, Y < 950)
$minX = $srcBmp.Width; $maxX = 0; $minY = 950; $maxY = 0
for ($y = 300; $y -lt 950; $y += 2) {
    for ($x = 0; $x -lt $srcBmp.Width; $x += 2) {
        if ($srcBmp.GetPixel($x, $y).A -gt 25) {
            if ($x -lt $minX) { $minX = $x }
            if ($x -gt $maxX) { $maxX = $x }
            if ($y -lt $minY) { $minY = $y }
            if ($y -gt $maxY) { $maxY = $y }
        }
    }
}

$embW = $maxX - $minX
$embH = $maxY - $minY

# 2. Generar lienzo cuadrado maestro con padding del 8%
$maxDim = [Math]::Max($embW, $embH)
$pad = [int]($maxDim * 0.08)
$masterSize = $maxDim + (2 * $pad)

$masterBmp = New-Object System.Drawing.Bitmap($masterSize, $masterSize, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($masterBmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.Clear([System.Drawing.Color]::Transparent)

$destX = $pad + [int](($maxDim - $embW) / 2)
$destY = $pad + [int](($maxDim - $embH) / 2)
$g.DrawImage($srcBmp, (New-Object System.Drawing.Rectangle($destX, $destY, $embW, $embH)), $minX, $minY, $embW, $embH, [System.Drawing.GraphicsUnit]::Pixel)
$g.Dispose()
$srcBmp.Dispose()

# Guardar version cuadrada PNG para incrustacion en memoria en WPF
$emblemPngPath = Join-Path $assetsDir "icon.png"
$masterBmp.Save($emblemPngPath, [System.Drawing.Imaging.ImageFormat]::Png)

# 3. Generar frames para resoluciones estandar de Windows
$sizes = @(16, 24, 32, 48, 64, 128, 256)
$pngStreams = @()

foreach ($sz in $sizes) {
    $resized = New-Object System.Drawing.Bitmap($sz, $sz, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $rg = [System.Drawing.Graphics]::FromImage($resized)
    $rg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $rg.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $rg.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $rg.Clear([System.Drawing.Color]::Transparent)
    $rg.DrawImage($masterBmp, 0, 0, $sz, $sz)
    $rg.Dispose()

    $ms = New-Object System.IO.MemoryStream
    $resized.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
    $resized.Dispose()
    $pngStreams += ,$ms.ToArray()
    $ms.Dispose()
}
$masterBmp.Dispose()

# 4. Escribir archivo binario .ICO de formato nativo Windows
$fs = [System.IO.File]::Create($outputPath)
$bw = New-Object System.IO.BinaryWriter($fs)

$bw.Write([uint16]0) # Reserved
$bw.Write([uint16]1) # Type 1 (Icon)
$bw.Write([uint16]$sizes.Count) # Image count

$dataOffset = 6 + (16 * $sizes.Count)

for ($i = 0; $i -lt $sizes.Count; $i++) {
    $sz = $sizes[$i]
    $wByte = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
    $hByte = if ($sz -ge 256) { [byte]0 } else { [byte]$sz }
    $bytes = $pngStreams[$i]

    $bw.Write($wByte)
    $bw.Write($hByte)
    $bw.Write([byte]0)
    $bw.Write([byte]0)
    $bw.Write([uint16]1)
    $bw.Write([uint16]32)
    $bw.Write([uint32]$bytes.Length)
    $bw.Write([uint32]$dataOffset)

    $dataOffset += $bytes.Length
}

for ($i = 0; $i -lt $sizes.Count; $i++) {
    $bw.Write($pngStreams[$i])
}

$bw.Close()
$fs.Close()

Write-Host "[OK] Icono multi-resolucion generado con exito: $outputPath" -ForegroundColor Green
