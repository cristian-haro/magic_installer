# ==============================================================================
# Magic Installer - Automated Batch Application Installer & Uninstaller for Windows
# ==============================================================================

# 1. Comprobar y solicitar elevacion de Administrador de forma invisible
$currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe -ArgumentList @("-NoProfile", "-WindowStyle", "Hidden", "-ExecutionPolicy", "Bypass", "-File", "`"$PSCommandPath`"") -Verb RunAs
    Exit
}

# Cargar librerias graficas WPF
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName PresentationCore
Add-Type -AssemblyName WindowsBase

# 2. Catalogo de aplicaciones disponibles para instalacion
$Apps = @(
    # --- NAVEGADORES ---
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Google Chrome"; Id = "Google.Chrome"; Descripcion = "Navegador web de Google"; Keywords = "chrome,google,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Mozilla Firefox"; Id = "Mozilla.Firefox"; Descripcion = "Navegador de codigo abierto"; Keywords = "firefox,mozilla,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Brave Browser"; Id = "Brave.Brave"; Descripcion = "Navegador enfocado en privacidad"; Keywords = "brave,browser,privacy" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Opera GX"; Id = "Opera.OperaGX"; Descripcion = "Navegador optimizado para gaming"; Keywords = "opera,gx,gaming,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Microsoft Edge"; Id = "Microsoft.Edge"; Descripcion = "Navegador nativo de Microsoft"; Keywords = "edge,microsoft,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Vivaldi"; Id = "VivaldiTechnologies.Vivaldi"; Descripcion = "Navegador altamente personalizable"; Keywords = "vivaldi,browser" }
    [PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Tor Browser"; Id = "TorProject.TorBrowser"; Descripcion = "Navegador para anonimato en red Tor"; Keywords = "tor,onion,privacy,browser" }

    # --- COMUNICACION Y MENSAJERIA ---
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Mozilla Thunderbird"; Id = "Mozilla.Thunderbird"; Descripcion = "Cliente de correo y calendario libre"; Keywords = "thunderbird,mail,email,correo" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Asana"; Id = "Asana.Asana"; Descripcion = "Gestion de tareas y proyectos de equipo"; Keywords = "asana,tasks,projects,equipo" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Discord"; Id = "Discord.Discord"; Descripcion = "Chat de voz y texto para comunidades"; Keywords = "discord,chat,voz,comunidad" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Telegram Desktop"; Id = "Telegram.TelegramDesktop"; Descripcion = "Mensajeria rapida y segura"; Keywords = "telegram,chat,mensajeria" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "WhatsApp"; Id = "WhatsApp.WhatsApp"; Descripcion = "Cliente oficial de WhatsApp"; Keywords = "whatsapp,chat,mensajes" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Zoom"; Id = "Zoom.Zoom"; Descripcion = "Reuniones y videollamadas"; Keywords = "zoom,videollamada,reuniones" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Microsoft Teams"; Id = "Microsoft.Teams"; Descripcion = "Comunicacion corporativa"; Keywords = "teams,microsoft,videollamada" }
    [PSCustomObject]@{ Categoria = "Mensajeria y Comunicacion"; Nombre = "Slack"; Id = "SlackTechnologies.Slack"; Descripcion = "Mensajeria para equipos de trabajo"; Keywords = "slack,chat,trabajo" }

    # --- MULTIMEDIA Y DISENO ---
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Figma"; Id = "Figma.Figma"; Descripcion = "Herramienta colaborativa de diseno de interfaces"; Keywords = "figma,design,ui,ux,diseno" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "VLC Media Player"; Id = "VideoLAN.VLC"; Descripcion = "Reproductor universal de medios"; Keywords = "vlc,video,audio,player" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Spotify"; Id = "Spotify.Spotify"; Descripcion = "Musica y podcasts en streaming"; Keywords = "spotify,musica,audio,streaming" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "OBS Studio"; Id = "OBSProject.OBSStudio"; Descripcion = "Grabacion y transmision de video"; Keywords = "obs,stream,grabacion,video" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Audacity"; Id = "Audacity.Audacity"; Descripcion = "Editor y grabador de audio"; Keywords = "audacity,audio,editor,sonido" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "HandBrake"; Id = "HandBrake.HandBrake"; Descripcion = "Conversor de formatos de video"; Keywords = "handbrake,video,conversor,mp4" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "GIMP"; Id = "GIMP.GIMP"; Descripcion = "Editor de fotos e imagenes"; Keywords = "gimp,imagen,foto,photoshop" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Paint.NET"; Id = "dotPDN.PaintDotNet"; Descripcion = "Editor grafico ligero"; Keywords = "paint,paint.net,imagen,dibujo" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "Blender"; Id = "BlenderFoundation.Blender"; Descripcion = "Modelado y animacion 3D"; Keywords = "blender,3d,animacion,render" }
    [PSCustomObject]@{ Categoria = "Multimedia y Diseno"; Nombre = "K-Lite Codec Pack Mega"; Id = "CodecGuide.K-LiteCodecPack.Mega"; Descripcion = "Coleccion de codecs multimedia"; Keywords = "klite,codec,video,audio" }

    # --- ALMACENAMIENTO EN LA NUBE ---
    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "Google Drive"; Id = "Google.GoogleDrive"; Descripcion = "Sincronizacion de Google Drive para escritorio"; Keywords = "google drive,cloud,nube,storage" }
    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "Microsoft OneDrive"; Id = "Microsoft.OneDrive"; Descripcion = "Nube integrada de Microsoft"; Keywords = "onedrive,microsoft,nube,cloud" }
    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "Dropbox"; Id = "Dropbox.Dropbox"; Descripcion = "Almacenamiento y sincronizacion en la nube"; Keywords = "dropbox,cloud,nube,archivos" }
    [PSCustomObject]@{ Categoria = "Almacenamiento en la Nube"; Nombre = "SugarSync"; Id = "IPVanish.SugarSync"; Descripcion = "Copia de seguridad y sincronizacion en la nube"; Keywords = "sugarsync,backup,cloud,nube" }

    # --- UTILIDADES DEL SISTEMA ---
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "7-Zip"; Id = "7zip.7zip"; Descripcion = "Compresor y extractor de archivos"; Keywords = "7zip,zip,rar,compresor" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "WinRAR"; Id = "RARLab.WinRAR"; Descripcion = "Gestion de archivos RAR y ZIP"; Keywords = "winrar,rar,zip,compresor" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Transmission"; Id = "Transmission.Transmission"; Descripcion = "Cliente Torrent rapido y ligero"; Keywords = "transmission,torrent,p2p,descargas" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "qBittorrent"; Id = "qBittorrent.qBittorrent"; Descripcion = "Cliente Torrent libre y sin publicidad"; Keywords = "qbittorrent,torrent,p2p,descargas" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Descripcion = "Control remoto y asistencia a distancia"; Keywords = "teamviewer,remoto,soporte" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "AnyDesk"; Id = "AnyDeskSoftwareGmbH.AnyDesk"; Descripcion = "Soporte y control remoto ultra fluido"; Keywords = "anydesk,remoto,soporte" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Glary Utilities"; Id = "Glarysoft.GlaryUtilities"; Descripcion = "Suite de limpieza y mantenimiento de sistema"; Keywords = "glary,limpieza,mantenimiento,optimizacion" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "CCleaner"; Id = "Piriform.CCleaner"; Descripcion = "Optimizador y limpiador de espacio"; Keywords = "ccleaner,limpieza,temporales" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "AutoHotkey"; Id = "AutoHotkey.AutoHotkey"; Descripcion = "Automatizacion y atajos de teclado personalizados"; Keywords = "autohotkey,ahk,macros,teclado" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Microsoft PowerToys"; Id = "Microsoft.PowerToys"; Descripcion = "Herramientas avanzadas para Windows"; Keywords = "powertoys,microsoft,utilidades" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Everything"; Id = "voidtools.Everything"; Descripcion = "Buscador ultrarrapido de archivos"; Keywords = "everything,search,buscar,archivos" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "TreeSize Free"; Id = "JAMSoftware.TreeSize.Free"; Descripcion = "Analizador de espacio en disco"; Keywords = "treesize,disco,espacio,almacenamiento" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Descripcion = "Salud SMART de discos SSD/HDD"; Keywords = "crystaldiskinfo,smart,disco,ssd,hdd" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "CPU-Z"; Id = "CPUID.CPU-Z"; Descripcion = "Datos de procesador y placa"; Keywords = "cpuz,cpu,hardware,procesador" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "GPU-Z"; Id = "TechPowerUp.GPU-Z"; Descripcion = "Datos tecnicos de tarjeta grafica"; Keywords = "gpuz,gpu,grafica,nvidia,amd" }
    [PSCustomObject]@{ Categoria = "Utilidades del Sistema"; Nombre = "Rufus"; Id = "Rufus.Rufus"; Descripcion = "Creacion de USBs de arranque"; Keywords = "rufus,usb,boot,iso" }

    # --- OFIMATICA Y NOTAS ---
    [PSCustomObject]@{ Categoria = "Ofimatica y Notas"; Nombre = "Adobe Acrobat Reader"; Id = "Adobe.Acrobat.Reader.64-bit"; Descripcion = "Visor de documentos PDF"; Keywords = "adobe,acrobat,reader,pdf" }
    [PSCustomObject]@{ Categoria = "Ofimatica y Notas"; Nombre = "LibreOffice"; Id = "TheDocumentFoundation.LibreOffice"; Descripcion = "Suite ofimatica de codigo abierto"; Keywords = "libreoffice,office,word,excel,docs" }
    [PSCustomObject]@{ Categoria = "Ofimatica y Notas"; Nombre = "Obsidian"; Id = "Obsidian.Obsidian"; Descripcion = "Base de conocimiento y notas en Markdown"; Keywords = "obsidian,notes,markdown,notas" }
    [PSCustomObject]@{ Categoria = "Ofimatica y Notas"; Nombre = "Notion"; Id = "Notion.Notion"; Descripcion = "Organizador de proyectos y notas"; Keywords = "notion,notas,proyectos,docs" }

    # --- DESARROLLO Y PROGRAMACION ---
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Visual Studio Code"; Id = "Microsoft.VisualStudioCode"; Descripcion = "Editor de codigo profesional"; Keywords = "vscode,visual studio code,editor,codigo" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Cursor"; Id = "Anysphere.Cursor"; Descripcion = "Editor de codigo impulsado por IA"; Keywords = "cursor,ai,codigo,editor" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Claude"; Id = "Anthropic.Claude"; Descripcion = "Cliente oficial de escritorio para Claude"; Keywords = "claude,anthropic,ai,ia" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Antigravity"; Id = "Google.Antigravity"; Descripcion = "Plataforma y entorno de desarrollo IA"; Keywords = "antigravity,google,ai,ia" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Codex CLI"; Id = "OpenAI.Codex"; Descripcion = "Herramienta de desarrollo de OpenAI"; Keywords = "codex,openai,chatgpt,cli" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Git"; Id = "Git.Git"; Descripcion = "Control de versiones Git"; Keywords = "git,vcs,github,version" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Python 3"; Id = "Python.Python.3.12"; Descripcion = "Lenguaje de programacion Python"; Keywords = "python,py,desarrollo,lenguaje" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Android Studio"; Id = "Google.AndroidStudio"; Descripcion = "IDE oficial para desarrollo Android"; Keywords = "android,studio,google,ide,apps" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Eclipse IDE"; Id = "EclipseFoundation.Eclipse.Java"; Descripcion = "IDE para desarrollo Java y proyectos empresariales"; Keywords = "eclipse,java,ide,enterprise" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Docker Desktop"; Id = "Docker.DockerDesktop"; Descripcion = "Plataforma de contenedores Docker"; Keywords = "docker,containers,contenedores" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "WinSCP / FTP"; Id = "WinSCP.WinSCP"; Descripcion = "Cliente FTP, SFTP y SCP para transferir archivos"; Keywords = "winscp,ftp,sftp,scp,archivos" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "GitHub Desktop"; Id = "GitHub.GitHubDesktop"; Descripcion = "Cliente visual de GitHub"; Keywords = "github,git,desktop,repos" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Notepad++"; Id = "Notepad++.Notepad++"; Descripcion = "Editor de texto avanzado con sintaxis"; Keywords = "notepad,editor,texto,codigo" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Node.js (LTS)"; Id = "OpenJS.NodeJS.LTS"; Descripcion = "Entorno de ejecucion JavaScript"; Keywords = "node,nodejs,javascript,npm" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Postman"; Id = "Postman.Postman"; Descripcion = "Prueba y diseno de APIs"; Keywords = "postman,api,rest,http" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "Windows Terminal"; Id = "Microsoft.WindowsTerminal"; Descripcion = "Terminal moderna para Windows"; Keywords = "terminal,windows terminal,console,powershell" }
    [PSCustomObject]@{ Categoria = "Desarrollo y Programacion"; Nombre = "DBeaver Community"; Id = "dbeaver.dbeaver"; Descripcion = "Gestor universal de bases de datos"; Keywords = "dbeaver,sql,database,db" }

    # --- GAMING ---
    [PSCustomObject]@{ Categoria = "Gaming y Tiendas"; Nombre = "Steam"; Id = "Valve.Steam"; Descripcion = "Tienda de videojuegos Steam"; Keywords = "steam,valve,games,juegos" }
    [PSCustomObject]@{ Categoria = "Gaming y Tiendas"; Nombre = "Epic Games Launcher"; Id = "EpicGames.EpicGamesLauncher"; Descripcion = "Lanzador de Epic Games"; Keywords = "epic,games,fortnite,juegos" }
    [PSCustomObject]@{ Categoria = "Gaming y Tiendas"; Nombre = "GOG Galaxy"; Id = "GOG.Galaxy"; Descripcion = "Juegos sin DRM de GOG"; Keywords = "gog,galaxy,cdprojekt,juegos" }
    [PSCustomObject]@{ Categoria = "Gaming y Tiendas"; Nombre = "EA App"; Id = "ElectronicArts.EADesktop"; Descripcion = "Lanzador oficial de EA"; Keywords = "ea,origin,electronic arts,juegos" }

    # --- SEGURIDAD ---
    [PSCustomObject]@{ Categoria = "Seguridad y Contrasenas"; Nombre = "Bitwarden"; Id = "Bitwarden.Bitwarden"; Descripcion = "Gestor de contrasenas en la nube"; Keywords = "bitwarden,password,seguridad,contrasenas" }
    [PSCustomObject]@{ Categoria = "Seguridad y Contrasenas"; Nombre = "KeePassXC"; Id = "KeePassXCTeam.KeePassXC"; Descripcion = "Gestor de contrasenas local seguro"; Keywords = "keepass,keepassxc,password,seguridad" }
    [PSCustomObject]@{ Categoria = "Seguridad y Contrasenas"; Nombre = "Malwarebytes"; Id = "Malwarebytes.Malwarebytes"; Descripcion = "Proteccion contra malware y virus"; Keywords = "malwarebytes,antivirus,malware,seguridad" }
)

# 3. Deteccion rapida de programas ya instalados en el sistema
$InstalledProgramsRegistry = @()
try {
    $regPaths = @(
        "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $InstalledProgramsRegistry = Get-ItemProperty $regPaths -ErrorAction SilentlyContinue | 
        Where-Object { $_.DisplayName } | 
        ForEach-Object { $_.DisplayName.ToLower() }
} catch { }

function Test-IsInstalled ($appName, $appId) {
    if (-not $InstalledProgramsRegistry) { return $false }
    $cleanName = $appName.ToLower().Split(" ")[0]
    
    foreach ($inst in $InstalledProgramsRegistry) {
        if ($inst.Contains($appName.ToLower()) -or ($cleanName.Length -gt 3 -and $inst.Contains($cleanName))) {
            return $true
        }
    }
    return $false
}

# 4. Diseno de la Ventana WPF
$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Magic Installer - Batch App Installer and Uninstaller" 
        Height="820" Width="1060" 
        WindowStartupLocation="CenterScreen" 
        Background="#F8FAFC" 
        FontFamily="Segoe UI">
    
    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
        </Grid.RowDefinitions>

        <!-- BARRA SUPERIOR GLOBAL: TITULO Y SELECTOR DE MODO -->
        <Border Grid.Row="0" Background="#0F172A" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*" />
                    <ColumnDefinition Width="Auto" />
                </Grid.ColumnDefinitions>
                
                <StackPanel Grid.Column="0" VerticalAlignment="Center">
                    <TextBlock Text="Magic Installer" FontSize="20" FontWeight="Bold" Foreground="White" />
                    <TextBlock Name="TxtGlobalSubtitle" Text="Instalacion y desinstalacion desatendida de aplicaciones por lotes." FontSize="13" Foreground="#94A3B8" Margin="0,3,0,0" />
                </StackPanel>
                
                <!-- Pestanas de Modo -->
                <Border Grid.Column="1" Background="#1E293B" CornerRadius="6" Padding="4" VerticalAlignment="Center">
                    <StackPanel Orientation="Horizontal">
                        <Button Name="BtnTabInstall" Content="Instalador" Padding="16,6" Background="#2563EB" Foreground="White" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand" />
                        <Button Name="BtnTabUninstall" Content="Desinstalador por Lotes" Padding="16,6" Margin="4,0,0,0" Background="Transparent" Foreground="#94A3B8" FontWeight="SemiBold" FontSize="12" BorderThickness="0" Cursor="Hand" />
                    </StackPanel>
                </Border>
            </Grid>
        </Border>

        <!-- CONTENIDO PRINCIPAL -->
        <Grid Grid.Row="1">
            
            <!-- VISTA 1: MODO INSTALADOR -->
            <Grid Name="ViewSelection" Visibility="Visible">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="*" />
                    <RowDefinition Height="Auto" />
                </Grid.RowDefinitions>

                <!-- Banner Verde de Actualizaciones Pendientes -->
                <Border Name="BannerUpdates" Grid.Row="0" Background="#059669" CornerRadius="8" Padding="16,12" Margin="0,0,0,12" Visibility="Collapsed">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>
                        
                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                            <TextBlock Name="TxtBannerTitle" Text="Actualizaciones del sistema disponibles" FontSize="14" FontWeight="Bold" Foreground="White" />
                            <TextBlock Name="TxtBannerSubtitle" Text="Se han detectado programas que pueden ser actualizados a su version mas reciente." FontSize="12" Foreground="#D1FAE5" Margin="0,2,0,0" />
                        </StackPanel>
                        
                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button Name="BtnDismissBanner" Content="Omitir" Padding="12,6" Margin="0,0,8,0" Background="#047857" Foreground="White" BorderThickness="0" Cursor="Hand" />
                            <Button Name="BtnUpdateSystem" Content="Actualizar Todo Ahora" Padding="16,7" Background="White" Foreground="#047857" FontWeight="Bold" FontSize="12" BorderThickness="0" Cursor="Hand" />
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- Barra de Herramientas de Busqueda y Acciones del Instalador -->
                <Border Grid.Row="1" Background="White" CornerRadius="8" Padding="14,10" Margin="0,0,0,12" BorderBrush="#E2E8F0" BorderThickness="1">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                            <TextBlock Text="Buscar aplicacion: " Foreground="#475569" FontWeight="Medium" VerticalAlignment="Center" Margin="0,0,8,0" FontSize="13" />
                            <Border Background="#F8FAFC" CornerRadius="6" Padding="8,4" BorderBrush="#CBD5E1" BorderThickness="1">
                                <TextBox Name="TxtSearch" Width="220" Background="Transparent" Foreground="#1E293B" BorderThickness="0" FontSize="12" VerticalAlignment="Center" />
                            </Border>
                        </StackPanel>

                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button Name="BtnDeselectAll" Content="Deseleccionar Todo" Padding="12,6" Margin="0,0,8,0" Background="#F1F5F9" Foreground="#475569" BorderThickness="1" BorderBrush="#E2E8F0" Cursor="Hand" />
                            <Button Name="BtnSelectAll" Content="Seleccionar Todo" Padding="12,6" Background="#F1F5F9" Foreground="#475569" BorderThickness="1" BorderBrush="#E2E8F0" Cursor="Hand" />
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- Contenedor de categorias con casillas -->
                <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
                    <WrapPanel Name="CategoriesContainer" Orientation="Horizontal" ItemWidth="495" />
                </ScrollViewer>

                <!-- Barra inferior Instalador -->
                <Border Grid.Row="3" Background="White" CornerRadius="8" Padding="16,14" Margin="0,12,0,0" BorderBrush="#E2E8F0" BorderThickness="1">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>
                        
                        <TextBlock Name="TxtCounter" Grid.Column="0" Text="0 aplicaciones seleccionadas" VerticalAlignment="Center" FontWeight="SemiBold" Foreground="#334155" FontSize="14" />
                        
                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                            <Button Name="BtnCancelar" Content="Salir" Padding="18,8" Margin="0,0,10,0" Background="#F1F5F9" Foreground="#475569" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand" />
                            <Button Name="BtnInstalar" Content="Instalar Seleccionadas" Padding="22,9" Background="#2563EB" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" Cursor="Hand" />
                        </StackPanel>
                    </Grid>
                </Border>
            </Grid>

            <!-- VISTA 2: MODO DESINSTALADOR POR LOTES -->
            <Grid Name="ViewUninstall" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="*" />
                    <RowDefinition Height="Auto" />
                </Grid.RowDefinitions>

                <!-- Barra de Herramientas de Busqueda y Acciones del Desinstalador -->
                <Border Grid.Row="0" Background="White" CornerRadius="8" Padding="14,10" Margin="0,0,0,12" BorderBrush="#E2E8F0" BorderThickness="1">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                            <TextBlock Text="Buscar programa instalado: " Foreground="#475569" FontWeight="Medium" VerticalAlignment="Center" Margin="0,0,8,0" FontSize="13" />
                            <Border Background="#F8FAFC" CornerRadius="6" Padding="8,4" BorderBrush="#CBD5E1" BorderThickness="1">
                                <TextBox Name="TxtSearchUninstall" Width="240" Background="Transparent" Foreground="#1E293B" BorderThickness="0" FontSize="12" VerticalAlignment="Center" />
                            </Border>
                        </StackPanel>

                        <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center">
                            <Button Name="BtnRefreshUninstall" Content="Recargar Lista" Padding="12,6" Margin="0,0,8,0" Background="#F1F5F9" Foreground="#475569" BorderThickness="1" BorderBrush="#E2E8F0" Cursor="Hand" />
                            <Button Name="BtnDeselectAllUninstall" Content="Deseleccionar Todo" Padding="12,6" Margin="0,0,8,0" Background="#F1F5F9" Foreground="#475569" BorderThickness="1" BorderBrush="#E2E8F0" Cursor="Hand" />
                            <Button Name="BtnSelectAllUninstall" Content="Seleccionar Todo" Padding="12,6" Background="#F1F5F9" Foreground="#475569" BorderThickness="1" BorderBrush="#E2E8F0" Cursor="Hand" />
                        </StackPanel>
                    </Grid>
                </Border>

                <!-- Lista de programas instalados -->
                <Border Grid.Row="1" Background="White" CornerRadius="8" BorderBrush="#E2E8F0" BorderThickness="1" Padding="10">
                    <Grid>
                        <!-- Mensaje de Carga Inicial -->
                        <StackPanel Name="PanelUninstallLoading" VerticalAlignment="Center" HorizontalAlignment="Center" Visibility="Visible">
                            <TextBlock Text="Escaneando programas instalados en el equipo..." FontSize="14" FontWeight="SemiBold" Foreground="#64748B" HorizontalAlignment="Center" Margin="0,0,0,6" />
                            <TextBlock Text="Por favor, espera unos segundos mientras Winget consulta el sistema." FontSize="12" Foreground="#94A3B8" HorizontalAlignment="Center" />
                        </StackPanel>

                        <ScrollViewer Name="ScrollUninstall" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled" Visibility="Collapsed">
                            <WrapPanel Name="UninstallItemsContainer" Orientation="Horizontal" ItemWidth="490" />
                        </ScrollViewer>
                    </Grid>
                </Border>

                <!-- Barra inferior Desinstalador -->
                <Border Grid.Row="2" Background="White" CornerRadius="8" Padding="16,14" Margin="0,12,0,0" BorderBrush="#E2E8F0" BorderThickness="1">
                    <Grid>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="Auto" />
                        </Grid.ColumnDefinitions>
                        
                        <TextBlock Name="TxtCounterUninstall" Grid.Column="0" Text="0 aplicaciones seleccionadas para desinstalar" VerticalAlignment="Center" FontWeight="SemiBold" Foreground="#334155" FontSize="14" />
                        
                        <StackPanel Grid.Column="1" Orientation="Horizontal">
                            <Button Name="BtnCancelarUninstall" Content="Salir" Padding="18,8" Margin="0,0,10,0" Background="#F1F5F9" Foreground="#475569" FontWeight="SemiBold" BorderThickness="0" Cursor="Hand" />
                            <Button Name="BtnDesinstalar" Content="Desinstalar Seleccionadas" Padding="22,9" Background="#DC2626" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" Cursor="Hand" />
                        </StackPanel>
                    </Grid>
                </Border>
            </Grid>

            <!-- VISTA 3: PROCESO EN VIVO (INSTALACION, ACTUALIZACION O DESINSTALACION) -->
            <Grid Name="ViewProgress" Visibility="Collapsed">
                <Grid.RowDefinitions>
                    <RowDefinition Height="Auto" />
                    <RowDefinition Height="*" />
                    <RowDefinition Height="Auto" />
                </Grid.RowDefinitions>

                <!-- Cabecera Progreso -->
                <Border Grid.Row="0" Background="#0F172A" CornerRadius="8" Padding="18,14" Margin="0,0,0,12">
                    <StackPanel>
                        <TextBlock Name="TxtProgressTitle" Text="Procesando operaciones..." FontSize="19" FontWeight="Bold" Foreground="White" />
                        <TextBlock Name="TxtProgressSubtitle" Text="Por favor, espera mientras se realizan las operaciones solicitadas." FontSize="13" Foreground="#94A3B8" Margin="0,3,0,10" />
                        
                        <ProgressBar Name="MainProgressBar" Height="14" Minimum="0" Maximum="100" Value="0" Background="#334155" Foreground="#10B981" BorderThickness="0" />
                    </StackPanel>
                </Border>

                <!-- Lista de aplicaciones con estado detallado -->
                <Border Grid.Row="1" Background="White" CornerRadius="8" BorderBrush="#E2E8F0" BorderThickness="1" Padding="14">
                    <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
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
                        
                        <TextBlock Name="TxtCurrentStatus" Grid.Column="0" Text="Preparando tareas..." VerticalAlignment="Center" Foreground="#64748B" FontSize="13" />
                        <Button Name="BtnFinalizar" Grid.Column="1" Content="Finalizar y Cerrar" Padding="22,9" Background="#10B981" Foreground="White" FontWeight="Bold" FontSize="13" BorderThickness="0" Cursor="Hand" Visibility="Collapsed" />
                    </Grid>
                </Border>
            </Grid>

        </Grid>
    </Grid>
</Window>
"@

# Cargar la ventana
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Obtener referencias a los controles de navegacion y pestañas
$btnTabInstall          = $window.FindName("BtnTabInstall")
$btnTabUninstall        = $window.FindName("BtnTabUninstall")
$txtGlobalSubtitle      = $window.FindName("TxtGlobalSubtitle")

# Vistas
$viewSelection          = $window.FindName("ViewSelection")
$viewUninstall          = $window.FindName("ViewUninstall")
$viewProgress           = $window.FindName("ViewProgress")

# Controles de Vista Instalador
$bannerUpdates          = $window.FindName("BannerUpdates")
$txtBannerTitle         = $window.FindName("TxtBannerTitle")
$txtBannerSubtitle      = $window.FindName("TxtBannerSubtitle")
$btnDismissBanner       = $window.FindName("BtnDismissBanner")
$btnUpdateSystem        = $window.FindName("BtnUpdateSystem")
$categoriesContainer    = $window.FindName("CategoriesContainer")
$txtCounter             = $window.FindName("TxtCounter")
$txtSearch              = $window.FindName("TxtSearch")
$btnSelectAll           = $window.FindName("BtnSelectAll")
$btnDeselectAll         = $window.FindName("BtnDeselectAll")
$btnInstalar            = $window.FindName("BtnInstalar")
$btnCancelar            = $window.FindName("BtnCancelar")

# Controles de Vista Desinstalador
$panelUninstallLoading  = $window.FindName("PanelUninstallLoading")
$scrollUninstall        = $window.FindName("ScrollUninstall")
$uninstallItemsContainer= $window.FindName("UninstallItemsContainer")
$txtSearchUninstall     = $window.FindName("TxtSearchUninstall")
$btnSelectAllUninstall  = $window.FindName("BtnSelectAllUninstall")
$btnDeselectAllUninstall= $window.FindName("BtnDeselectAllUninstall")
$btnRefreshUninstall    = $window.FindName("BtnRefreshUninstall")
$txtCounterUninstall    = $window.FindName("TxtCounterUninstall")
$btnCancelarUninstall   = $window.FindName("BtnCancelarUninstall")
$btnDesinstalar         = $window.FindName("BtnDesinstalar")

# Controles de Vista Progreso
$txtProgressTitle       = $window.FindName("TxtProgressTitle")
$txtProgressSubtitle    = $window.FindName("TxtProgressSubtitle")
$mainProgressBar        = $window.FindName("MainProgressBar")
$progressItemsContainer = $window.FindName("ProgressItemsContainer")
$txtCurrentStatus       = $window.FindName("TxtCurrentStatus")
$btnFinalizar           = $window.FindName("BtnFinalizar")

# Colecciones globales en memoria
$allCheckBoxesInstall   = [System.Collections.Generic.List[System.Windows.Controls.CheckBox]]::new()
$allCardsInstall        = [System.Collections.Generic.List[PSCustomObject]]::new()

$allCheckBoxesUninstall = [System.Collections.Generic.List[System.Windows.Controls.CheckBox]]::new()
$allRowsUninstall       = [System.Collections.Generic.List[PSCustomObject]]::new()

$Script:AvailableUpgrades = @()
$Script:InstalledAppsLoaded = $false

# Refresco fluido de la interfaz
function Do-Events {
    $frame = [System.Windows.Threading.DispatcherFrame]::new()
    [System.Windows.Threading.Dispatcher]::CurrentDispatcher.BeginInvoke(
        [System.Windows.Threading.DispatcherPriority]::Background,
        [System.Action[System.Windows.Threading.DispatcherFrame]]{ param($f) $f.Continue = $false },
        $frame
    ) | Out-Null
    [System.Windows.Threading.Dispatcher]::PushFrame($frame)
}

# ==============================================================================
# CONFIGURACION VISTA INSTALADOR
# ==============================================================================
$UpdateInstallCounter = {
    $count = ($allCheckBoxesInstall | Where-Object { $_.IsChecked -eq $true }).Count
    if ($count -eq 1) {
        $txtCounter.Text = "1 aplicacion seleccionada"
    } else {
        $txtCounter.Text = "$count aplicaciones seleccionadas"
    }
}

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

    $cardCheckboxes = [System.Collections.Generic.List[System.Windows.Controls.CheckBox]]::new()

    foreach ($app in $group.Group) {
        $cb = [System.Windows.Controls.CheckBox]::new()
        $cb.Margin = [System.Windows.Thickness]::new(2, 3, 2, 3)
        $cb.Tag = $app
        $cb.Cursor = [System.Windows.Input.Cursors]::Hand

        $cbPanel = [System.Windows.Controls.StackPanel]::new()
        $cbPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $nameText = [System.Windows.Controls.TextBlock]::new()
        $nameText.Text = $app.Nombre
        $nameText.FontWeight = [System.Windows.FontWeights]::SemiBold
        $nameText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
        $nameText.Margin = [System.Windows.Thickness]::new(4, 0, 6, 0)
        $cbPanel.Children.Add($nameText) | Out-Null

        $isInstalled = Test-IsInstalled -appName $app.Nombre -appId $app.Id
        if ($isInstalled) {
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

        $cb.Add_Checked({ & $UpdateInstallCounter })
        $cb.Add_Unchecked({ & $UpdateInstallCounter })

        $allCheckBoxesInstall.Add($cb)
        $cardCheckboxes.Add($cb)
        $stack.Children.Add($cb) | Out-Null
    }

    $card.Child = $stack
    $categoriesContainer.Children.Add($card) | Out-Null

    $allCardsInstall.Add([PSCustomObject]@{
        Card       = $card
        Checkboxes = $cardCheckboxes
        Categoria  = $group.Name
    })
}

$txtSearch.Add_TextChanged({
    $query = $txtSearch.Text.Trim().ToLower()

    foreach ($cardObj in $allCardsInstall) {
        $visibleCount = 0
        foreach ($cb in $cardObj.Checkboxes) {
            $app = $cb.Tag
            $match = ($query -eq "") -or `
                     ($app.Nombre.ToLower().Contains($query)) -or `
                     ($app.Descripcion.ToLower().Contains($query)) -or `
                     ($app.Keywords.ToLower().Contains($query)) -or `
                     ($cardObj.Categoria.ToLower().Contains($query))

            if ($match) {
                $cb.Visibility = [System.Windows.Visibility]::Visible
                $visibleCount++
            } else {
                $cb.Visibility = [System.Windows.Visibility]::Collapsed
            }
        }

        if ($visibleCount -gt 0) {
            $cardObj.Card.Visibility = [System.Windows.Visibility]::Visible
        } else {
            $cardObj.Card.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
})

$btnSelectAll.Add_Click({
    foreach ($cb in $allCheckBoxesInstall) { 
        if ($cb.Visibility -eq [System.Windows.Visibility]::Visible) {
            $cb.IsChecked = $true 
        }
    }
    & $UpdateInstallCounter
})

$btnDeselectAll.Add_Click({
    foreach ($cb in $allCheckBoxesInstall) { $cb.IsChecked = $false }
    & $UpdateInstallCounter
})

$btnDismissBanner.Add_Click({
    $bannerUpdates.Visibility = [System.Windows.Visibility]::Collapsed
})

# ==============================================================================
# CONFIGURACION VISTA DESINSTALADOR POR LOTES
# ==============================================================================
$UpdateUninstallCounter = {
    $count = ($allCheckBoxesUninstall | Where-Object { $_.IsChecked -eq $true }).Count
    if ($count -eq 1) {
        $txtCounterUninstall.Text = "1 aplicacion seleccionada para desinstalar"
    } else {
        $txtCounterUninstall.Text = "$count aplicaciones seleccionadas para desinstalar"
    }
}

function Load-InstalledAppsAsync {
    $panelUninstallLoading.Visibility = [System.Windows.Visibility]::Visible
    $scrollUninstall.Visibility       = [System.Windows.Visibility]::Collapsed
    $uninstallItemsContainer.Children.Clear()
    $allCheckBoxesUninstall.Clear()
    $allRowsUninstall.Clear()
    & $UpdateUninstallCounter

    $Script:ListJob = Start-Job -ScriptBlock {
        try {
            $raw = winget.exe list --accept-source-agreements 2>$null
            $lines = $raw -split "`r?`n"
            $sep = -1
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match '^-{10,}') { $sep = $i; break }
            }
            if ($sep -eq -1) { return @() }
            $hdr = $lines[$sep - 1]
            $idCol = $hdr.IndexOf('Id')
            if ($idCol -eq -1) { return @() }

            $list = @()
            for ($i = $sep + 1; $i -lt $lines.Count; $i++) {
                $l = $lines[$i]
                if ([string]::IsNullOrWhiteSpace($l.Trim())) { continue }
                if ($l.Length -gt $idCol) {
                    $name = $l.Substring(0, [Math]::Min($idCol, $l.Length)).Trim()
                    $rest = $l.Substring($idCol).Trim()
                    $tokens = -split $rest
                    if ($tokens.Count -ge 1) {
                        $id = $tokens[0]
                        $version = if ($tokens.Count -ge 2) { $tokens[1] } else { '' }
                        
                        # Filtrar paquetes internos de Windows y dependencias del sistema
                        if ($name -and $id -notmatch '^MSIX\\Microsoft\.VCLibs' -and $id -notmatch '^MSIX\\Microsoft\.UI\.Xaml' -and $id -notmatch '^Microsoft\.WindowsAppRuntime' -and $id -notmatch '^MSIX\\Microsoft\.Winget') {
                            $list += [PSCustomObject]@{
                                Nombre  = $name
                                Id      = $id
                                Version = $version
                            }
                        }
                    }
                }
            }
            return $list | Sort-Object Nombre
        } catch {
            return @()
        }
    }

    $Script:ListTimer = [System.Windows.Threading.DispatcherTimer]::new()
    $Script:ListTimer.Interval = [TimeSpan]::FromMilliseconds(400)
    $Script:ListTimer.Add_Tick({
        if ($Script:ListJob -and $Script:ListJob.State -ne 'Running') {
            $Script:ListTimer.Stop()
            $results = Receive-Job $Script:ListJob -ErrorAction SilentlyContinue
            Remove-Job $Script:ListJob -Force -ErrorAction SilentlyContinue

            $panelUninstallLoading.Visibility = [System.Windows.Visibility]::Collapsed
            $scrollUninstall.Visibility       = [System.Windows.Visibility]::Visible

            if ($results) {
                foreach ($app in $results) {
                    $rowBorder = [System.Windows.Controls.Border]::new()
                    $rowBorder.Background = [System.Windows.Media.Brushes]::White
                    $rowBorder.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E2E8F0")
                    $rowBorder.BorderThickness = [System.Windows.Thickness]::new(1)
                    $rowBorder.CornerRadius = [System.Windows.CornerRadius]::new(6)
                    $rowBorder.Margin = [System.Windows.Thickness]::new(4)
                    $rowBorder.Padding = [System.Windows.Thickness]::new(10, 8, 10, 8)

                    $cb = [System.Windows.Controls.CheckBox]::new()
                    $cb.Tag = $app
                    $cb.Cursor = [System.Windows.Input.Cursors]::Hand
                    $cb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center

                    $cbPanel = [System.Windows.Controls.StackPanel]::new()
                    $cbPanel.Orientation = [System.Windows.Controls.Orientation]::Vertical
                    $cbPanel.Margin = [System.Windows.Thickness]::new(4, 0, 0, 0)

                    $nameText = [System.Windows.Controls.TextBlock]::new()
                    $nameText.Text = $app.Nombre
                    $nameText.FontWeight = [System.Windows.FontWeights]::SemiBold
                    $nameText.FontSize = 13
                    $nameText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
                    $cbPanel.Children.Add($nameText) | Out-Null

                    $subInfoPanel = [System.Windows.Controls.StackPanel]::new()
                    $subInfoPanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal
                    $subInfoPanel.Margin = [System.Windows.Thickness]::new(0, 2, 0, 0)

                    if ($app.Version) {
                        $verBadge = [System.Windows.Controls.TextBlock]::new()
                        $verBadge.Text = "v$($app.Version)  "
                        $verBadge.FontSize = 11
                        $verBadge.FontWeight = [System.Windows.FontWeights]::Medium
                        $verBadge.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#059669")
                        $subInfoPanel.Children.Add($verBadge) | Out-Null
                    }

                    $idText = [System.Windows.Controls.TextBlock]::new()
                    $idText.Text = "ID: $($app.Id)"
                    $idText.FontSize = 11
                    $idText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
                    $subInfoPanel.Children.Add($idText) | Out-Null

                    $cbPanel.Children.Add($subInfoPanel) | Out-Null
                    $cb.Content = $cbPanel

                    $cb.Add_Checked({ & $UpdateUninstallCounter })
                    $cb.Add_Unchecked({ & $UpdateUninstallCounter })

                    $rowBorder.Child = $cb
                    $uninstallItemsContainer.Children.Add($rowBorder) | Out-Null

                    $allCheckBoxesUninstall.Add($cb)
                    $allRowsUninstall.Add([PSCustomObject]@{
                        Border   = $rowBorder
                        CheckBox = $cb
                        App      = $app
                    })
                }
            }
            $Script:InstalledAppsLoaded = $true
        }
    })
    $Script:ListTimer.Start()
}

$txtSearchUninstall.Add_TextChanged({
    $query = $txtSearchUninstall.Text.Trim().ToLower()

    foreach ($item in $allRowsUninstall) {
        $app = $item.App
        $match = ($query -eq "") -or `
                 ($app.Nombre.ToLower().Contains($query)) -or `
                 ($app.Id.ToLower().Contains($query)) -or `
                 ($app.Version.ToLower().Contains($query))

        if ($match) {
            $item.Border.Visibility = [System.Windows.Visibility]::Visible
        } else {
            $item.Border.Visibility = [System.Windows.Visibility]::Collapsed
        }
    }
})

$btnSelectAllUninstall.Add_Click({
    foreach ($cb in $allCheckBoxesUninstall) { 
        if ($cb.Parent.Visibility -eq [System.Windows.Visibility]::Visible) {
            $cb.IsChecked = $true 
        }
    }
    & $UpdateUninstallCounter
})

$btnDeselectAllUninstall.Add_Click({
    foreach ($cb in $allCheckBoxesUninstall) { $cb.IsChecked = $false }
    & $UpdateUninstallCounter
})

$btnRefreshUninstall.Add_Click({
    Load-InstalledAppsAsync
})

# ==============================================================================
# CAMBIO DE PESTANAS (MODO INSTALADOR / MODO DESINSTALADOR)
# ==============================================================================
$btnTabInstall.Add_Click({
    $btnTabInstall.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
    $btnTabInstall.Foreground = [System.Windows.Media.Brushes]::White
    $btnTabInstall.FontWeight = [System.Windows.FontWeights]::Bold

    $btnTabUninstall.Background = [System.Windows.Media.Brushes]::Transparent
    $btnTabUninstall.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $btnTabUninstall.FontWeight = [System.Windows.FontWeights]::SemiBold

    $txtGlobalSubtitle.Text = "Selecciona las aplicaciones que deseas instalar de forma desatendida."
    $viewSelection.Visibility = [System.Windows.Visibility]::Visible
    $viewUninstall.Visibility = [System.Windows.Visibility]::Collapsed
    $viewProgress.Visibility  = [System.Windows.Visibility]::Collapsed
})

$btnTabUninstall.Add_Click({
    $btnTabUninstall.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
    $btnTabUninstall.Foreground = [System.Windows.Media.Brushes]::White
    $btnTabUninstall.FontWeight = [System.Windows.FontWeights]::Bold

    $btnTabInstall.Background = [System.Windows.Media.Brushes]::Transparent
    $btnTabInstall.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
    $btnTabInstall.FontWeight = [System.Windows.FontWeights]::SemiBold

    $txtGlobalSubtitle.Text = "Selecciona las aplicaciones instaladas que deseas eliminar por lotes de tu equipo."
    $viewSelection.Visibility = [System.Windows.Visibility]::Collapsed
    $viewUninstall.Visibility = [System.Windows.Visibility]::Visible
    $viewProgress.Visibility  = [System.Windows.Visibility]::Collapsed

    if (-not $Script:InstalledAppsLoaded) {
        Load-InstalledAppsAsync
    }
})

# Botones de Salir y Cerrar
$btnCancelar.Add_Click({ $window.Close() })
$btnCancelarUninstall.Add_Click({ $window.Close() })
$btnFinalizar.Add_Click({ $window.Close() })

# ==============================================================================
# ACCION 1: ACTUALIZACION DESDE BANNER VERDE
# ==============================================================================
$btnUpdateSystem.Add_Click({
    if (-not $Script:AvailableUpgrades -or $Script:AvailableUpgrades.Count -eq 0) { return }

    $itemsToUpdate = $Script:AvailableUpgrades

    $viewSelection.Visibility = [System.Windows.Visibility]::Collapsed
    $viewUninstall.Visibility = [System.Windows.Visibility]::Collapsed
    $viewProgress.Visibility  = [System.Windows.Visibility]::Visible
    Do-Events

    $statusMap = @{}
    $progressItemsContainer.Children.Clear()

    foreach ($app in $itemsToUpdate) {
        $row = [System.Windows.Controls.Border]::new()
        $row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F8FAFC")
        $row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E2E8F0")
        $row.BorderThickness = [System.Windows.Thickness]::new(1)
        $row.CornerRadius = [System.Windows.CornerRadius]::new(6)
        $row.Padding = [System.Windows.Thickness]::new(12, 10, 12, 10)
        $row.Margin = [System.Windows.Thickness]::new(0, 0, 0, 6)

        $gridRow = [System.Windows.Controls.Grid]::new()
        $col1 = [System.Windows.Controls.ColumnDefinition]::new()
        $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $col2 = [System.Windows.Controls.ColumnDefinition]::new()
        $col2.Width = [System.Windows.GridLength]::Auto
        $gridRow.ColumnDefinitions.Add($col1)
        $gridRow.ColumnDefinitions.Add($col2)

        $titlePanel = [System.Windows.Controls.StackPanel]::new()
        $titlePanel.Orientation = [System.Windows.Controls.Orientation]::Horizontal

        $appName = [System.Windows.Controls.TextBlock]::new()
        $appName.Text = $app.Nombre
        $appName.FontWeight = [System.Windows.FontWeights]::SemiBold
        $appName.FontSize = 13
        $appName.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
        $titlePanel.Children.Add($appName) | Out-Null

        $verText = [System.Windows.Controls.TextBlock]::new()
        $verText.Text = "  ($($app.Actual) -> $($app.Disponible))"
        $verText.FontSize = 11
        $verText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#64748B")
        $verText.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
        $titlePanel.Children.Add($verText) | Out-Null

        [System.Windows.Controls.Grid]::SetColumn($titlePanel, 0)
        $gridRow.Children.Add($titlePanel) | Out-Null

        $appStatus = [System.Windows.Controls.TextBlock]::new()
        $appStatus.Text = "En espera..."
        $appStatus.FontWeight = [System.Windows.FontWeights]::Medium
        $appStatus.FontSize = 12
        $appStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
        [System.Windows.Controls.Grid]::SetColumn($appStatus, 1)
        $gridRow.Children.Add($appStatus) | Out-Null

        $row.Child = $gridRow
        $progressItemsContainer.Children.Add($row) | Out-Null

        $statusMap[$app.Id] = @{
            Row    = $row
            Status = $appStatus
        }
    }

    $totalApps = $itemsToUpdate.Count
    $mainProgressBar.Maximum = $totalApps
    $mainProgressBar.Value = 0
    Do-Events

    $successCount = 0
    $failedCount = 0
    $index = 0

    foreach ($app in $itemsToUpdate) {
        $index++
        $txtProgressTitle.Text = "Actualizando aplicaciones del sistema ($index de $totalApps)..."
        $txtCurrentStatus.Text = "Descargando e instalando actualizacion de $($app.Nombre)..."
        
        $item = $statusMap[$app.Id]
        $item.Status.Text = "Actualizando..."
        $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
        $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EFF6FF")
        $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BFDBFE")
        Do-Events

        $proc = Start-Process -FilePath "winget.exe" `
            -ArgumentList "upgrade --id `"$($app.Id)`" -e --silent --accept-source-agreements --accept-package-agreements --include-unknown" `
            -NoNewWindow -PassThru -Wait

        if ($proc.ExitCode -eq 0) {
            $item.Status.Text = "Actualizado con exito"
            $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#16A34A")
            $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F0FDF4")
            $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BBF7D0")
            $successCount++
        } else {
            $retry = Start-Process -FilePath "winget.exe" `
                -ArgumentList "upgrade --id `"$($app.Id)`" -e --accept-source-agreements --accept-package-agreements" `
                -NoNewWindow -PassThru -Wait

            if ($retry.ExitCode -eq 0) {
                $item.Status.Text = "Actualizado con exito"
                $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#16A34A")
                $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F0FDF4")
                $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BBF7D0")
                $successCount++
            } else {
                $item.Status.Text = "No completado (Codigo: $($retry.ExitCode))"
                $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
                $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FEF2F2")
                $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FECACA")
                $failedCount++
            }
        }

        $mainProgressBar.Value = $index
        Do-Events
    }

    $txtProgressTitle.Text = "Actualizacion del sistema finalizada"
    $txtProgressSubtitle.Text = "Se completaron $successCount de $totalApps actualizaciones correctamente."
    $txtCurrentStatus.Text = "Todas las tareas han concluido."
    $btnFinalizar.Visibility = [System.Windows.Visibility]::Visible
    Do-Events
})

# ==============================================================================
# ACCION 2: INSTALACION DE APLICACIONES SELECCIONADAS
# ==============================================================================
$btnInstalar.Add_Click({
    $selected = @($allCheckBoxesInstall | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    
    if ($selected.Count -eq 0) {
        [System.Windows.MessageBox]::Show("Por favor, marca al menos una casilla antes de continuar.", "Ninguna aplicacion seleccionada", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
        return
    }

    $viewSelection.Visibility = [System.Windows.Visibility]::Collapsed
    $viewUninstall.Visibility = [System.Windows.Visibility]::Collapsed
    $viewProgress.Visibility  = [System.Windows.Visibility]::Visible
    Do-Events

    $statusMap = @{}
    $progressItemsContainer.Children.Clear()

    foreach ($app in $selected) {
        $row = [System.Windows.Controls.Border]::new()
        $row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F8FAFC")
        $row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E2E8F0")
        $row.BorderThickness = [System.Windows.Thickness]::new(1)
        $row.CornerRadius = [System.Windows.CornerRadius]::new(6)
        $row.Padding = [System.Windows.Thickness]::new(12, 10, 12, 10)
        $row.Margin = [System.Windows.Thickness]::new(0, 0, 0, 6)

        $gridRow = [System.Windows.Controls.Grid]::new()
        $col1 = [System.Windows.Controls.ColumnDefinition]::new()
        $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $col2 = [System.Windows.Controls.ColumnDefinition]::new()
        $col2.Width = [System.Windows.GridLength]::Auto
        $gridRow.ColumnDefinitions.Add($col1)
        $gridRow.ColumnDefinitions.Add($col2)

        $appName = [System.Windows.Controls.TextBlock]::new()
        $appName.Text = $app.Nombre
        $appName.FontWeight = [System.Windows.FontWeights]::SemiBold
        $appName.FontSize = 13
        $appName.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
        [System.Windows.Controls.Grid]::SetColumn($appName, 0)
        $gridRow.Children.Add($appName) | Out-Null

        $appStatus = [System.Windows.Controls.TextBlock]::new()
        $appStatus.Text = "En espera..."
        $appStatus.FontWeight = [System.Windows.FontWeights]::Medium
        $appStatus.FontSize = 12
        $appStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
        [System.Windows.Controls.Grid]::SetColumn($appStatus, 1)
        $gridRow.Children.Add($appStatus) | Out-Null

        $row.Child = $gridRow
        $progressItemsContainer.Children.Add($row) | Out-Null

        $statusMap[$app.Id] = @{
            Row    = $row
            Status = $appStatus
        }
    }

    $totalApps = $selected.Count
    $mainProgressBar.Maximum = $totalApps
    $mainProgressBar.Value = 0
    Do-Events

    $txtCurrentStatus.Text = "Sincronizando fuentes de Winget..."
    Do-Events
    $pSource = Start-Process -FilePath "winget.exe" -ArgumentList "source update" -NoNewWindow -PassThru -Wait

    $successCount = 0
    $failedCount = 0
    $index = 0

    foreach ($app in $selected) {
        $index++
        $txtProgressTitle.Text = "Instalando aplicaciones ($index de $totalApps)..."
        $txtCurrentStatus.Text = "Descargando e instalando $($app.Nombre)..."
        
        $item = $statusMap[$app.Id]
        $item.Status.Text = "Instalando..."
        $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#2563EB")
        $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#EFF6FF")
        $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BFDBFE")
        Do-Events

        $proc = Start-Process -FilePath "winget.exe" `
            -ArgumentList "install --id `"$($app.Id)`" -e --silent --accept-source-agreements --accept-package-agreements --include-unknown" `
            -NoNewWindow -PassThru -Wait

        if ($proc.ExitCode -eq 0) {
            $item.Status.Text = "Completado con exito"
            $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#16A34A")
            $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F0FDF4")
            $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BBF7D0")
            $successCount++
        } else {
            $retry = Start-Process -FilePath "winget.exe" `
                -ArgumentList "install --id `"$($app.Id)`" -e --accept-source-agreements --accept-package-agreements" `
                -NoNewWindow -PassThru -Wait

            if ($retry.ExitCode -eq 0) {
                $item.Status.Text = "Completado con exito"
                $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#16A34A")
                $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F0FDF4")
                $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BBF7D0")
                $successCount++
            } else {
                $item.Status.Text = "No completado (Codigo: $($retry.ExitCode))"
                $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
                $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FEF2F2")
                $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FECACA")
                $failedCount++
            }
        }

        $mainProgressBar.Value = $index
        Do-Events
    }

    $txtProgressTitle.Text = "Proceso de instalacion finalizado"
    $txtProgressSubtitle.Text = "Se completaron $successCount de $totalApps instalaciones correctamente."
    $txtCurrentStatus.Text = "Todas las tareas han concluido."
    $btnFinalizar.Visibility = [System.Windows.Visibility]::Visible
    Do-Events
})

# ==============================================================================
# ACCION 3: DESINSTALACION DE APLICACIONES SELECCIONADAS (Desinstalador por Lotes)
# ==============================================================================
$btnDesinstalar.Add_Click({
    $selected = @($allCheckBoxesUninstall | Where-Object { $_.IsChecked -eq $true } | ForEach-Object { $_.Tag })
    
    if ($selected.Count -eq 0) {
        [System.Windows.MessageBox]::Show("Por favor, marca al menos un programa para desinstalar.", "Ningun programa seleccionado", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Warning) | Out-Null
        return
    }

    $count = $selected.Count
    $confirm = [System.Windows.MessageBox]::Show(
        "Confirmas que deseas desinstalar las $count aplicaciones seleccionadas de tu equipo? Esta operacion eliminara los programas seleccionados.",
        "Confirmar Desinstalacion por Lotes",
        [System.Windows.MessageBoxButton]::YesNo,
        [System.Windows.MessageBoxImage]::Warning
    )

    if ($confirm -ne [System.Windows.MessageBoxResult]::Yes) {
        return
    }

    $viewSelection.Visibility = [System.Windows.Visibility]::Collapsed
    $viewUninstall.Visibility = [System.Windows.Visibility]::Collapsed
    $viewProgress.Visibility  = [System.Windows.Visibility]::Visible
    Do-Events

    $statusMap = @{}
    $progressItemsContainer.Children.Clear()

    foreach ($app in $selected) {
        $row = [System.Windows.Controls.Border]::new()
        $row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F8FAFC")
        $row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#E2E8F0")
        $row.BorderThickness = [System.Windows.Thickness]::new(1)
        $row.CornerRadius = [System.Windows.CornerRadius]::new(6)
        $row.Padding = [System.Windows.Thickness]::new(12, 10, 12, 10)
        $row.Margin = [System.Windows.Thickness]::new(0, 0, 0, 6)

        $gridRow = [System.Windows.Controls.Grid]::new()
        $col1 = [System.Windows.Controls.ColumnDefinition]::new()
        $col1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
        $col2 = [System.Windows.Controls.ColumnDefinition]::new()
        $col2.Width = [System.Windows.GridLength]::Auto
        $gridRow.ColumnDefinitions.Add($col1)
        $gridRow.ColumnDefinitions.Add($col2)

        $appName = [System.Windows.Controls.TextBlock]::new()
        $appName.Text = $app.Nombre
        $appName.FontWeight = [System.Windows.FontWeights]::SemiBold
        $appName.FontSize = 13
        $appName.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1E293B")
        [System.Windows.Controls.Grid]::SetColumn($appName, 0)
        $gridRow.Children.Add($appName) | Out-Null

        $appStatus = [System.Windows.Controls.TextBlock]::new()
        $appStatus.Text = "En espera..."
        $appStatus.FontWeight = [System.Windows.FontWeights]::Medium
        $appStatus.FontSize = 12
        $appStatus.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#94A3B8")
        [System.Windows.Controls.Grid]::SetColumn($appStatus, 1)
        $gridRow.Children.Add($appStatus) | Out-Null

        $row.Child = $gridRow
        $progressItemsContainer.Children.Add($row) | Out-Null

        $statusMap[$app.Id] = @{
            Row    = $row
            Status = $appStatus
        }
    }

    $totalApps = $selected.Count
    $mainProgressBar.Maximum = $totalApps
    $mainProgressBar.Value = 0
    Do-Events

    $successCount = 0
    $failedCount = 0
    $index = 0

    foreach ($app in $selected) {
        $index++
        $txtProgressTitle.Text = "Desinstalando aplicaciones ($index de $totalApps)..."
        $txtCurrentStatus.Text = "Desinstalando $($app.Nombre)..."
        
        $item = $statusMap[$app.Id]
        $item.Status.Text = "Desinstalando..."
        $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
        $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FEF2F2")
        $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FECACA")
        Do-Events

        $proc = Start-Process -FilePath "winget.exe" `
            -ArgumentList "uninstall --id `"$($app.Id)`" --silent --accept-source-agreements" `
            -NoNewWindow -PassThru -Wait

        if ($proc.ExitCode -eq 0) {
            $item.Status.Text = "Desinstalado con exito"
            $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#16A34A")
            $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F0FDF4")
            $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BBF7D0")
            $successCount++
        } else {
            $retry = Start-Process -FilePath "winget.exe" `
                -ArgumentList "uninstall --name `"$($app.Nombre)`" --silent --accept-source-agreements" `
                -NoNewWindow -PassThru -Wait

            if ($retry.ExitCode -eq 0) {
                $item.Status.Text = "Desinstalado con exito"
                $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#16A34A")
                $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#F0FDF4")
                $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#BBF7D0")
                $successCount++
            } else {
                $item.Status.Text = "No completado (Codigo: $($retry.ExitCode))"
                $item.Status.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#DC2626")
                $item.Row.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FEF2F2")
                $item.Row.BorderBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#FECACA")
                $failedCount++
            }
        }

        $mainProgressBar.Value = $index
        Do-Events
    }

    $txtProgressTitle.Text = "Proceso de desinstalacion finalizado"
    $txtProgressSubtitle.Text = "Se completaron $successCount de $totalApps desinstalaciones correctamente."
    $txtCurrentStatus.Text = "Todas las tareas han concluido."
    $btnFinalizar.Visibility = [System.Windows.Visibility]::Visible
    Do-Events
})

# ==============================================================================
# COMPROBACION ASINCRONA DE ACTUALIZACIONES AL INICIAR LA VENTANA
# ==============================================================================
$window.Add_ContentRendered({
    $Script:UpdateJob = Start-Job -ScriptBlock {
        try {
            $raw = winget.exe upgrade --accept-source-agreements 2>$null
            $lines = $raw -split "`r?`n"
            $sep = -1
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match '^-{10,}') { $sep = $i; break }
            }
            if ($sep -eq -1) { return @() }
            $hdr = $lines[$sep - 1]
            $idCol = $hdr.IndexOf('Id')
            if ($idCol -eq -1) { return @() }

            $upgrades = @()
            for ($i = $sep + 1; $i -lt $lines.Count; $i++) {
                $l = $lines[$i]
                if ([string]::IsNullOrWhiteSpace($l.Trim())) { continue }
                if ($l -match 'actualizaciones disponibles' -or $l -match 'upgrades available' -or $l -match 'paquete\(s\)') { break }
                if ($l.Length -gt $idCol) {
                    $name = $l.Substring(0, [Math]::Min($idCol, $l.Length)).Trim()
                    $tokens = -split ($l.Substring($idCol))
                    if ($tokens.Count -ge 2) {
                        $upgrades += [PSCustomObject]@{
                            Nombre     = $name
                            Id         = $tokens[0]
                            Actual     = $tokens[1]
                            Disponible = if ($tokens.Count -ge 3) { $tokens[2] } else { '' }
                        }
                    }
                }
            }
            return $upgrades
        } catch {
            return @()
        }
    }

    $Script:Timer = [System.Windows.Threading.DispatcherTimer]::new()
    $Script:Timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $Script:Timer.Add_Tick({
        if ($Script:UpdateJob -and $Script:UpdateJob.State -ne 'Running') {
            $Script:Timer.Stop()
            $results = Receive-Job $Script:UpdateJob -ErrorAction SilentlyContinue
            Remove-Job $Script:UpdateJob -Force -ErrorAction SilentlyContinue

            if ($results) {
                $upgradesList = @($results)
                if ($upgradesList.Count -gt 0) {
                    $Script:AvailableUpgrades = $upgradesList
                    $count = $upgradesList.Count
                    
                    $txtBannerTitle.Text = if ($count -eq 1) { "1 actualizacion del sistema disponible" } else { "$count actualizaciones del sistema disponibles" }
                    $txtBannerSubtitle.Text = "Se han detectado programas instalados con versiones mas recientes listas para actualizar."
                    $btnUpdateSystem.Content = if ($count -eq 1) { "Actualizar Programa" } else { "Actualizar Todos ($count)" }
                    $bannerUpdates.Visibility = [System.Windows.Visibility]::Visible
                }
            }
        }
    })
    $Script:Timer.Start()
})

$window.Add_Closed({
    if ($Script:Timer) { $Script:Timer.Stop() }
    if ($Script:ListTimer) { $Script:ListTimer.Stop() }
    if ($Script:UpdateJob) {
        Stop-Job $Script:UpdateJob -Force -ErrorAction SilentlyContinue
        Remove-Job $Script:UpdateJob -Force -ErrorAction SilentlyContinue
    }
    if ($Script:ListJob) {
        Stop-Job $Script:ListJob -Force -ErrorAction SilentlyContinue
        Remove-Job $Script:ListJob -Force -ErrorAction SilentlyContinue
    }
})

# Mostrar ventana
$window.ShowDialog() | Out-Null
