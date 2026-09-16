# ==============================================================================
# Script de Renderizado y Capturas Automaticas de Magic Installer
# ==============================================================================

Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

$rootDir = (Get-Item $PSScriptRoot).Parent.FullName
$assetsDir = Join-Path $rootDir "assets\screenshots"
if (-not (Test-Path $assetsDir)) {
    New-Item -ItemType Directory -Path $assetsDir -Force | Out-Null
}

$Apps = @(
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Google Chrome"; Id = "Google.Chrome"; Descripcion = "Navegador web de Google"; Keywords = "chrome,google,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Descripcion = "Navegador de codigo abierto"; Keywords = "firefox,mozilla,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Brave Browser"; Id = "Brave.Brave"; Descripcion = "Navegador enfocado en privacidad"; Keywords = "brave,browser,privacy" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Opera GX"; Id = "Opera.OperaGX"; Descripcion = "Navegador optimizado para gaming"; Keywords = "opera,gx,gaming,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Microsoft Edge"; Id = "Microsoft.Edge"; Descripcion = "Navegador nativo de Microsoft"; Keywords = "edge,microsoft,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Vivaldi"; Id = "VivaldiTechnologies.Vivaldi"; Descripcion = "Navegador altamente personalizable"; Keywords = "vivaldi,browser" }
    
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Mozilla Thunderbird"; Id = "Mozilla.Thunderbird"; Descripcion = "Cliente de correo y calendario libre"; Keywords = "thunderbird,mail,email" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Asana"; Id = "Asana.Asana"; Descripcion = "Gestion de tareas y proyectos de equipo"; Keywords = "asana,tasks,projects" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Discord"; Id = "Discord.Discord"; Descripcion = "Chat de voz y texto para comunidades"; Keywords = "discord,chat,voz" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Telegram Desktop"; Id = "Telegram.TelegramDesktop"; Descripcion = "Mensajeria rapida y segura"; Keywords = "telegram,chat" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "WhatsApp"; Id = "WhatsApp.WhatsApp"; Descripcion = "Cliente oficial de WhatsApp"; Keywords = "whatsapp,chat" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Slack"; Id = "SlackTechnologies.Slack"; Descripcion = "Mensajeria para equipos de trabajo"; Keywords = "slack,chat" }

    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Figma"; Id = "Figma.Figma"; Descripcion = "Herramienta colaborativa de diseno de interfaces"; Keywords = "figma,ui,ux" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "VLC Media Player"; Id = "VideoLAN.VLC"; Descripcion = "Reproductor universal de medios"; Keywords = "vlc,video,player" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Spotify"; Id = "Spotify.Spotify"; Descripcion = "Musica y podcasts en streaming"; Keywords = "spotify,musica" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "OBS Studio"; Id = "OBSProject.OBSStudio"; Descripcion = "Grabacion y transmision de video"; Keywords = "obs,stream" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Blender"; Id = "BlenderFoundation.Blender"; Descripcion = "Modelado y animacion 3D"; Keywords = "blender,3d" }

    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "Google Drive"; Id = "Google.GoogleDrive"; Descripcion = "Sincronizacion de Google Drive para escritorio"; Keywords = "google drive,cloud" }
    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "Microsoft OneDrive"; Id = "Microsoft.OneDrive"; Descripcion = "Nube integrada de Microsoft"; Keywords = "onedrive,cloud" }
    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "Dropbox"; Id = "Dropbox.Dropbox"; Descripcion = "Almacenamiento y sincronizacion en la nube"; Keywords = "dropbox,cloud" }

    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "7-Zip"; Id = "7zip.7zip"; Descripcion = "Compresor y extractor de archivos"; Keywords = "7zip,zip,rar" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "WinRAR"; Id = "RARLab.WinRAR"; Descripcion = "Gestion de archivos RAR y ZIP"; Keywords = "winrar,rar,zip" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Transmission"; Id = "Transmission.Transmission"; Descripcion = "Cliente Torrent rapido y ligero"; Keywords = "transmission,torrent" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Everything"; Id = "voidtools.Everything"; Descripcion = "Buscador ultrarrapido de archivos"; Keywords = "everything,search" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Descripcion = "Salud SMART de discos SSD/HDD"; Keywords = "crystaldiskinfo,smart" }

    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Descripcion = "Editor de codigo profesional"; Keywords = "vscode,editor" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Cursor"; Id = "Anysphere.Cursor"; Descripcion = "Editor de codigo impulsado por IA"; Keywords = "cursor,ai,editor" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Claude"; Id = "Anthropic.Claude"; Descripcion = "Cliente oficial de escritorio para Claude"; Keywords = "claude,ai" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Git"; Id = "Git.Git"; Descripcion = "Control de versiones Git"; Keywords = "git,github" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Python 3"; Id = "Python.Python.3.12"; Descripcion = "Lenguaje de programacion Python"; Keywords = "python,py" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Docker Desktop"; Id = "Docker.DockerDesktop"; Descripcion = "Plataforma de contenedores Docker"; Keywords = "docker,containers" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Windows Terminal"; Id = "Microsoft.WindowsTerminal"; Descripcion = "Terminal moderna para Windows"; Keywords = "terminal,console" }

    [PSCustomObject]@{ Categoria = "Gaming y Tiendas"; Nombre = "Steam"; Id = "Valve.Steam"; Descripcion = "Tienda de videojuegos Steam"; Keywords = "steam,games" }
    [PSCustomObject]@{ Categoria = "Gaming y Tiendas"; Nombre = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher"; Descripcion = "Lanzador de Epic Games"; Keywords = "epic,games" }

    [PSCustomObject]@{ Categoria = "Seguridad y Contrasenas"; Nombre = "Bitwarden"; Id = "Bitwarden.Bitwarden"; Descripcion = "Gestor de contrasenas en la nube"; Keywords = "bitwarden,password" }
    [PSCustomObject]@{ Categoria = "Seguridad y Contrasenas"; Nombre = "Malwarebytes"; Id = "Malwarebytes.Malwarebytes"; Descripcion = "Proteccion contra malware y virus"; Keywords = "malwarebytes,antivirus" }
)

function Save-WpfElementAsPng ($rootElement, $outputPath, $width = 1060, $height = 760) {
    $rootElement.Width = $width
    $rootElement.Height = $height

    $rootElement.Measure([System.Windows.Size]::new($width, $height))
    $rootElement.Arrange([System.Windows.Rect]::new(0, 0, $width, $height))
    $rootElement.UpdateLayout()

    $dv = [System.Windows.Media.DrawingVisual]::new()
    $dc = $dv.RenderOpen()
    $bgBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F8FAFC")
    $dc.DrawRectangle($bgBrush, $null, [System.Windows.Rect]::new(0, 0, $width, $height))
    $dc.DrawRectangle([System.Windows.Media.VisualBrush]::new($rootElement), $null, [System.Windows.Rect]::new(0, 0, $width, $height))
    $dc.Close()

    $rtb = [System.Windows.Media.Imaging.RenderTargetBitmap]::new($width, $height, 96, 96, [System.Windows.Media.PixelFormats]::Pbgra32)
    $rtb.Render($dv)

    $encoder = [System.Windows.Media.Imaging.PngBitmapEncoder]::new()
    $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($rtb))

    $stream = [System.IO.File]::Create($outputPath)
    $encoder.Save($stream)
    $stream.Close()
}

# -------------------------------------------------------------
# 1. RENDER VISTA DE SELECCION
# -------------------------------------------------------------
$xamlSelection = @"
<UserControl xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             Background="#F8FAFC" FontFamily="Segoe UI" Width="1060" Height="760">
    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>

        <!-- Cabecera Seleccion con Buscador -->
        <Border Grid.Row="0" Background="#0F172A" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>
                
                <StackPanel Grid.Column="0">
                    <TextBlock Text="Magic Installer" FontSize="20" FontWeight="Bold" Foreground="White" />
                    <TextBlock Text="Selecciona las aplicaciones que deseas instalar de forma desatendida." FontSize="13" Foreground="#94A3B8" Margin="0,3,0,0" />
                </StackPanel>
                
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                    <Border Background="#1E293B" CornerRadius="6" Padding="8,4" Margin="0,0,12,0" BorderBrush="#334155" BorderThickness="1">
                        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
                            <TextBlock Text="Buscar: " Foreground="#94A3B8" VerticalAlignment="Center" Margin="0,0,6,0" FontSize="12" />
                            <TextBox Width="170" Background="Transparent" Foreground="White" BorderThickness="0" FontSize="12" VerticalAlignment="Center" />
                        </StackPanel>
                    </Border>

                    <Button Content="Deseleccionar Todo" Padding="12,7" Margin="0,0,8,0" Background="#1E293B" Foreground="White" BorderThickness="1" BorderBrush="#334155" />
                    <Button Content="Seleccionar Todo" Padding="12,7" Background="#1E293B" Foreground="White" BorderThickness="1" BorderBrush="#334155" />
                </StackPanel>
            </Grid>
        </Border>

        <!-- Contenedor de categorias con casillas -->
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Disabled" HorizontalScrollBarVisibility="Disabled">
            <WrapPanel Name="CategoriesContainer" Orientation="Horizontal" ItemWidth="495" />
        </ScrollViewer>

        <!-- Barra inferior -->
        <Border Grid.Row="2" Background="White" CornerRadius="8" Padding="16,14" Margin="0,12,0,0" BorderBrush="#E2E8F0" BorderThickness="1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>
                
                <TextBlock Text="4 aplicaciones seleccionadas" VerticalAlignment="Center" FontWeight="SemiBold" Foreground="#334155" FontSize="14" />
                
                <StackPanel Grid.Column="1" Orientation="Horizontal">
                    <Button Content="Salir" Padding="18,8" Margin="0,0,10,0" Background="#F1F5F9" Foreground="#475569" FontWeight="SemiBold" BorderThickness="0" />
                    <Button Content="Instalar Seleccionadas" Padding="22,9" Background="#2563EB" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" />
                </StackPanel>
            </Grid>
        </Border>
    </Grid>
</UserControl>
"@

$reader1 = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlSelection))
$rootSelection = [System.Windows.Markup.XamlReader]::Load($reader1)
$catContainer1 = $rootSelection.FindName("CategoriesContainer")

$groupedApps = $Apps | Group-Object Categoria
foreach ($group in $groupedApps) {
    $card = [System.Windows.Controls.Border]::new()
    $card.Background = [System.Windows.Media.Brushes]::White
    $card.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E2E8F0")
    $card.BorderThickness = [System.Windows.Thickness]::new(1)
    $card.CornerRadius = [System.Windows.CornerRadius]::new(6)
    $card.Margin = [System.Windows.Thickness]::new(5)
    $card.Padding = [System.Windows.Thickness]::new(12, 10, 12, 10)

    $stack = [System.Windows.Controls.StackPanel]::new()
    $header = [System.Windows.Controls.TextBlock]::new()
    $header.Text = $group.Name
    $header.FontWeight = [System.Windows.FontWeights]::Bold
    $header.FontSize = 14
    $header.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0F172A")
    $header.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)
    $stack.Children.Add($header) | Out-Null

    $sep = [System.Windows.Controls.Separator]::new()
    $sep.Margin = [System.Windows.Thickness]::new(0, 0, 0, 6)
    $sep.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F1F5F9")
    $stack.Children.Add($sep) | Out-Null

    foreach ($app in $group.Group) {
        $cb = [System.Windows.Controls.CheckBox]::new()
        $cb.Margin = [System.Windows.Thickness]::new(2, 3, 2, 3)

        if ($app.Nombre -in @("Google Chrome", "7-Zip", "Visual Studio Code", "VLC Media Player")) {
            $cb.IsChecked = $true
        }

        $cbPanel = [System.Windows.Controls.StackPanel]::new()
        $cbPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $nameText = [System.Windows.Controls.TextBlock]::new()
        $nameText.Text = $app.Nombre
        $nameText.FontWeight = [System.Windows.FontWeights]::SemiBold
        $nameText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
        $nameText.Margin = [System.Windows.Thickness]::new(4, 0, 6, 0)
        $cbPanel.Children.Add($nameText) | Out-Null

        if ($app.Nombre -in @("Google Chrome", "Microsoft Edge", "7-Zip", "Git", "Windows Terminal")) {
            $badgeText = [System.Windows.Controls.TextBlock]::new()
            $badgeText.Text = "[Instalado]"
            $badgeText.FontSize = 10
            $badgeText.FontWeight = [System.Windows.FontWeights]::Bold
            $badgeText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#059669")
            $badgeText.Margin = [System.Windows.Thickness]::new(0, 0, 6, 0)
            $badgeText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
            $cbPanel.Children.Add($badgeText) | Out-Null
        }

        $descText = [System.Windows.Controls.TextBlock]::new()
        $descText.Text = "($($app.Descripcion))"
        $descText.FontSize = 11
        $descText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#64748B")
        $descText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $cbPanel.Children.Add($descText) | Out-Null

        $cb.Content = $cbPanel
        $stack.Children.Add($cb) | Out-Null
    }
    $card.Child = $stack
    $catContainer1.Children.Add($card) | Out-Null
}

$imgSelectionPath = Join-Path $assetsDir "magic_installer_selection.png"
Save-WpfElementAsPng -rootElement $rootSelection -outputPath $imgSelectionPath
Write-Host "[OK] Captura 1 generada correctamente: $imgSelectionPath" -ForegroundColor Green

# -------------------------------------------------------------
# 2. RENDER VISTA DE PROGRESO
# -------------------------------------------------------------
$xamlProgress = @"
<UserControl xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
             xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
             Background="#F8FAFC" FontFamily="Segoe UI" Width="1060" Height="760">
    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
        </Grid.RowDefinitions>

        <!-- Cabecera Progreso -->
        <Border Grid.Row="0" Background="#0F172A" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
            <StackPanel>
                <TextBlock Text="Instalando aplicaciones (3 de 4)..." FontSize="19" FontWeight="Bold" Foreground="White" />
                <TextBlock Text="Por favor, espera mientras se descargan e instalan los programas seleccionados." FontSize="13" Foreground="#94A3B8" Margin="0,3,0,10" />
                
                <ProgressBar Height="14" Minimum="0" Maximum="4" Value="3" Background="#334155" Foreground="#10B981" BorderThickness="0" />
            </StackPanel>
        </Border>

        <!-- Lista de aplicaciones con estado -->
        <Border Grid.Row="1" Background="White" CornerRadius="8" BorderBrush="#E2E8F0" BorderThickness="1" Padding="14">
            <ScrollViewer VerticalScrollBarVisibility="Disabled" HorizontalScrollBarVisibility="Disabled">
                <StackPanel Name="ProgressItemsContainer" />
            </ScrollViewer>
        </Border>

        <!-- Barra inferior de progreso -->
        <Border Grid.Row="2" Background="White" CornerRadius="8" Padding="16,14" Margin="0,12,0,0" BorderBrush="#E2E8F0" BorderThickness="1">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>
                
                <TextBlock Text="Descargando e instalando Visual Studio Code..." VerticalAlignment="Center" Foreground="#64748B" FontSize="13" />
                <Button Content="Finalizar y Cerrar" Padding="22,9" Background="#10B981" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" />
            </Grid>
        </Border>
    </Grid>
</UserControl>
"@

$reader2 = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xamlProgress))
$rootProgress = [System.Windows.Markup.XamlReader]::Load($reader2)
$progressItems2 = $rootProgress.FindName("ProgressItemsContainer")

$progressMock = @(
    @{ Nombre = "Google Chrome"; Status = "Completado con exito"; Color = "#16A34A"; Bg = "#F0FDF4"; Border = "#BBF7D0" },
    @{ Nombre = "7-Zip"; Status = "Completado con exito"; Color = "#16A34A"; Bg = "#F0FDF4"; Border = "#BBF7D0" },
    @{ Nombre = "Visual Studio Code"; Status = "Instalando..."; Color = "#2563EB"; Bg = "#EFF6FF"; Border = "#BFDBFE" },
    @{ Nombre = "VLC Media Player"; Status = "En espera..."; Color = "#94A3B8"; Bg = "#F8FAFC"; Border = "#E2E8F0" }
)

foreach ($item in $progressMock) {
    $row = [System.Windows.Controls.Border]::new()
    $row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString($item.Bg)
    $row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($item.Border)
    $row.BorderThickness = [System.Windows.Thickness]::new(1)
    $row.CornerRadius = [System.Windows.CornerRadius]::new(6)
    $row.Padding = [System.Windows.Thickness]::new(14, 12, 14, 12)
    $row.Margin = [System.Windows.Thickness]::new(0, 0, 0, 8)

    $gridRow = [System.Windows.Controls.Grid]::new()
    $col1 = [System.Windows.Controls.ColumnDefinition]::new()
    $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $col2 = [System.Windows.Controls.ColumnDefinition]::new()
    $col2.Width = [System.Windows.GridLength]::Auto
    $gridRow.ColumnDefinitions.Add($col1)
    $gridRow.ColumnDefinitions.Add($col2)

    $appName = [System.Windows.Controls.TextBlock]::new()
    $appName.Text = $item.Nombre
    $appName.FontWeight = [System.Windows.FontWeights]::SemiBold
    $appName.FontSize = 14
    $appName.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
    [System.Windows.Controls.Grid]::SetColumn($appName, 0)
    $gridRow.Children.Add($appName) | Out-Null

    $appStatus = [System.Windows.Controls.TextBlock]::new()
    $appStatus.Text = $item.Status
    $appStatus.FontWeight = [System.Windows.FontWeights]::Bold
    $appStatus.FontSize = 13
    $appStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($item.Color)
    [System.Windows.Controls.Grid]::SetColumn($appStatus, 1)
    $gridRow.Children.Add($appStatus) | Out-Null

    $row.Child = $gridRow
    $progressItems2.Children.Add($row) | Out-Null
}

$imgProgressPath = Join-Path $assetsDir "magic_installer_progress.png"
Save-WpfElementAsPng -rootElement $rootProgress -outputPath $imgProgressPath
Write-Host "[OK] Captura 2 generada correctamente: $imgProgressPath" -ForegroundColor Green
