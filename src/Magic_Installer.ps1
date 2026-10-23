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

    # --- COMUNICACION ---
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Mozilla Thunderbird"; Id = "Mozilla.Thunderbird"; Descripcion = "Cliente de correo y calendario libre"; Keywords = "thunderbird,mail,email,correo" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Asana"; Id = "Asana.Asana"; Descripcion = "Gestion de tareas y proyectos de equipo"; Keywords = "asana,tasks,projects,equipo" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Discord"; Id = "Discord.Discord"; Descripcion = "Chat de voz y texto para comunidades"; Keywords = "discord,chat,voz,comunidad" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Telegram Desktop"; Id = "Telegram.TelegramDesktop"; Descripcion = "Mensajeria rapida y segura"; Keywords = "telegram,chat,mensajeria" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "WhatsApp"; Id = "WhatsApp.WhatsApp"; Descripcion = "Cliente oficial de WhatsApp"; Keywords = "whatsapp,chat,mensajes" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Zoom"; Id = "Zoom.Zoom"; Descripcion = "Reuniones y videollamadas"; Keywords = "zoom,videollamada,reuniones" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Microsoft Teams"; Id = "Microsoft.Teams"; Descripcion = "Comunicacion corporativa"; Keywords = "teams,microsoft,videollamada" }
    [PSCustomObject]@{ Categoria = "Comunicacion"; Nombre = "Slack"; Id = "SlackTechnologies.Slack"; Descripcion = "Mensajeria para equipos de trabajo"; Keywords = "slack,chat,trabajo" }

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

    # --- CLOUD ---
    [PSCustomObject]@{ Categoria = "Cloud"; Nombre = "Google Drive"; Id = "Google.GoogleDrive"; Descripcion = "Sincronizacion de Google Drive para escritorio"; Keywords = "google drive,cloud,nube,storage" }
    [PSCustomObject]@{ Categoria = "Cloud"; Nombre = "Microsoft OneDrive"; Id = "Microsoft.OneDrive"; Descripcion = "Nube integrada de Microsoft"; Keywords = "onedrive,microsoft,nube,cloud" }
    [PSCustomObject]@{ Categoria = "Cloud"; Nombre = "Dropbox"; Id = "Dropbox.Dropbox"; Descripcion = "Almacenamiento y sincronizacion en la nube"; Keywords = "dropbox,cloud,nube,archivos" }
    [PSCustomObject]@{ Categoria = "Cloud"; Nombre = "SugarSync"; Id = "IPVanish.SugarSync"; Descripcion = "Copia de seguridad y sincronizacion en la nube"; Keywords = "sugarsync,backup,cloud,nube" }

    # --- SISTEMA ---
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "7-Zip"; Id = "7zip.7zip"; Descripcion = "Compresor y extractor de archivos"; Keywords = "7zip,zip,rar,compresor" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "WinRAR"; Id = "RARLab.WinRAR"; Descripcion = "Gestion de archivos RAR y ZIP"; Keywords = "winrar,rar,zip,compresor" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "Transmission"; Id = "Transmission.Transmission"; Descripcion = "Cliente Torrent rapido y ligero"; Keywords = "transmission,torrent,p2p,descargas" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "qBittorrent"; Id = "qBittorrent.qBittorrent"; Descripcion = "Cliente Torrent libre y sin publicidad"; Keywords = "qbittorrent,torrent,p2p,descargas" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "TeamViewer"; Id = "TeamViewer.TeamViewer"; Descripcion = "Control remoto y asistencia a distancia"; Keywords = "teamviewer,remoto,soporte" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "AnyDesk"; Id = "AnyDeskSoftwareGmbH.AnyDesk"; Descripcion = "Soporte y control remoto ultra fluido"; Keywords = "anydesk,remoto,soporte" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "Glary Utilities"; Id = "Glarysoft.GlaryUtilities"; Descripcion = "Suite de limpieza y mantenimiento de sistema"; Keywords = "glary,limpieza,mantenimiento,optimizacion" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "CCleaner"; Id = "Piriform.CCleaner"; Descripcion = "Optimizador y limpiador de espacio"; Keywords = "ccleaner,limpieza,temporales" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "AutoHotkey"; Id = "AutoHotkey.AutoHotkey"; Descripcion = "Automatizacion y atajos de teclado personalizados"; Keywords = "autohotkey,ahk,macros,teclado" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "Microsoft PowerToys"; Id = "Microsoft.PowerToys"; Descripcion = "Herramientas avanzadas para Windows"; Keywords = "powertoys,microsoft,utilidades" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "Everything"; Id = "voidtools.Everything"; Descripcion = "Buscador ultrarrapido de archivos"; Keywords = "everything,search,buscar,archivos" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "TreeSize Free"; Id = "JAMSoftware.TreeSize.Free"; Descripcion = "Analizador de espacio en disco"; Keywords = "treesize,disco,espacio,almacenamiento" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "CrystalDiskInfo"; Id = "CrystalDewWorld.CrystalDiskInfo"; Descripcion = "Salud SMART de discos SSD/HDD"; Keywords = "crystaldiskinfo,smart,disco,ssd,hdd" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "CPU-Z"; Id = "CPUID.CPU-Z"; Descripcion = "Datos de procesador y placa"; Keywords = "cpuz,cpu,hardware,procesador" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "GPU-Z"; Id = "TechPowerUp.GPU-Z"; Descripcion = "Datos tecnicos de tarjeta grafica"; Keywords = "gpuz,gpu,grafica,nvidia,amd" }
    [PSCustomObject]@{ Categoria = "Sistema"; Nombre = "Rufus"; Id = "Rufus.Rufus"; Descripcion = "Creacion de USBs de arranque"; Keywords = "rufus,usb,boot,iso" }

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
        Height="840" Width="1060" 
        WindowStartupLocation="CenterScreen" 
        Background="#F8FAFC" 
        FontFamily="Segoe UI">
    
    <Grid Margin="18">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto" />
            <RowDefinition Height="*" />
            <RowDefinition Height="Auto" />
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

        <!-- BARRA DE INFORMACION DE HARDWARE Y SISTEMA (PIE DE VENTANA) -->
        <Border Grid.Row="2" Background="#0F172A" CornerRadius="8" Padding="14,9" Margin="0,10,0,0">
            <Grid>
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="1.1*" />
                    <ColumnDefinition Width="1.3*" />
                    <ColumnDefinition Width="1.0*" />
                    <ColumnDefinition Width="1.1*" />
                </Grid.ColumnDefinitions>

                <!-- Sistema Operativo -->
                <StackPanel Grid.Column="0" Orientation="Horizontal" VerticalAlignment="Center">
                    <TextBlock Text="SO: " FontWeight="Bold" Foreground="#38BDF8" FontSize="11" />
                    <TextBlock Name="TxtSysOS" Text="Cargando..." Foreground="#94A3B8" FontSize="11" TextTrimming="CharacterEllipsis" />
                </StackPanel>

                <!-- Procesador -->
                <StackPanel Grid.Column="1" Orientation="Horizontal" VerticalAlignment="Center" Margin="6,0,0,0">
                    <TextBlock Text="CPU: " FontWeight="Bold" Foreground="#38BDF8" FontSize="11" />
                    <TextBlock Name="TxtSysCPU" Text="Cargando..." Foreground="#94A3B8" FontSize="11" TextTrimming="CharacterEllipsis" />
                </StackPanel>

                <!-- Memoria RAM -->
                <StackPanel Grid.Column="2" Orientation="Horizontal" VerticalAlignment="Center" Margin="6,0,0,0">
                    <TextBlock Text="RAM: " FontWeight="Bold" Foreground="#38BDF8" FontSize="11" />
                    <TextBlock Name="TxtSysRAM" Text="Cargando..." Foreground="#94A3B8" FontSize="11" TextTrimming="CharacterEllipsis" />
                </StackPanel>

                <!-- Almacenamiento Disco C -->
                <StackPanel Grid.Column="3" Orientation="Horizontal" VerticalAlignment="Center" Margin="6,0,0,0">
                    <TextBlock Text="Disco C: " FontWeight="Bold" Foreground="#38BDF8" FontSize="11" />
                    <TextBlock Name="TxtSysDisk" Text="Cargando..." Foreground="#94A3B8" FontSize="11" TextTrimming="CharacterEllipsis" />
                </StackPanel>
            </Grid>
        </Border>

    </Grid>
</Window>
"@

# Cargar la ventana
$reader = [System.Xml.XmlReader]::Create([System.IO.StringReader]::new($xaml))
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# Establecer Icono de la Ventana (Favicon de WPF y Barra de Tareas)
try {
    $embeddedIconBase64 = "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"
    $iconBytes = [System.Convert]::FromBase64String($embeddedIconBase64)
    $iconStream = New-Object System.IO.MemoryStream(,)
    $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create($iconStream, [System.Windows.Media.Imaging.BitmapCreateOptions]::None, [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad)
} catch {
    $iconCandidates = @(
        (Join-Path $PSScriptRoot "..\assets\icon.ico"),
        (Join-Path (Get-Location).Path "assets\icon.ico"),
        (Join-Path $env:TEMP "MagicInstaller\assets\icon.ico")
    )
    foreach ($cand in $iconCandidates) {
        if (Test-Path $cand) {
            try {
                $window.Icon = [System.Windows.Media.Imaging.BitmapFrame]::Create([System.Uri]::new((Get-Item $cand).FullName))
                break
            } catch { }
        }
    }
}

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

# Controles de Informacion de Sistema
$txtSysOS               = $window.FindName("TxtSysOS")
$txtSysCPU              = $window.FindName("TxtSysCPU")
$txtSysRAM              = $window.FindName("TxtSysRAM")
$txtSysDisk             = $window.FindName("TxtSysDisk")

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
# COMPROBACIONES ASINCRONAS AL INICIAR LA VENTANA (Actualizaciones y Hardware)
# ==============================================================================
$window.Add_ContentRendered({
    # 1. Comprobacion de Actualizaciones
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

    # 2. Comprobacion de Hardware y Sistema
    $Script:SysInfoJob = Start-Job -ScriptBlock {
        try {
            $os = Get-CimInstance Win32_OperatingSystem -ErrorAction SilentlyContinue
            $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1
            $cs = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue
            $drive = Get-PSDrive C -ErrorAction SilentlyContinue

            $osName = if ($os) { $os.Caption -replace 'Microsoft ', '' } else { 'Windows' }
            $cpuName = if ($cpu) { ($cpu.Name -replace '\(R\)|\(TM\)|\s+Processor', '').Trim() } else { 'CPU' }

            $totalRam = if ($cs) { [Math]::Round($cs.TotalPhysicalMemory / 1GB, 1) } else { 0 }
            $freeRam = if ($os) { [Math]::Round($os.FreePhysicalMemory / 1024 / 1024, 1) } else { 0 }
            $usedRam = [Math]::Round($totalRam - $freeRam, 1)

            $freeDisk = if ($drive) { [Math]::Round($drive.Free / 1GB, 1) } else { 0 }
            $totalDisk = if ($drive) { [Math]::Round(($drive.Used + $drive.Free) / 1GB, 1) } else { 0 }

            return [PSCustomObject]@{
                OS   = $osName
                CPU  = $cpuName
                RAM  = "$usedRam GB / $totalRam GB"
                Disk = "$freeDisk GB libres de $totalDisk GB"
            }
        } catch {
            return $null
        }
    }

    $Script:Timer = [System.Windows.Threading.DispatcherTimer]::new()
    $Script:Timer.Interval = [TimeSpan]::FromMilliseconds(500)
    $Script:Timer.Add_Tick({
        # Procesar Actualizaciones
        if ($Script:UpdateJob -and $Script:UpdateJob.State -ne 'Running') {
            $results = Receive-Job $Script:UpdateJob -ErrorAction SilentlyContinue
            Remove-Job $Script:UpdateJob -Force -ErrorAction SilentlyContinue
            $Script:UpdateJob = $null

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

        # Procesar Informacion de Sistema
        if ($Script:SysInfoJob -and $Script:SysInfoJob.State -ne 'Running') {
            $sysData = Receive-Job $Script:SysInfoJob -ErrorAction SilentlyContinue
            Remove-Job $Script:SysInfoJob -Force -ErrorAction SilentlyContinue
            $Script:SysInfoJob = $null

            if ($sysData) {
                $txtSysOS.Text   = $sysData.OS
                $txtSysCPU.Text  = $sysData.CPU
                $txtSysRAM.Text  = $sysData.RAM
                $txtSysDisk.Text = $sysData.Disk
            }
        }

        if (-not $Script:UpdateJob -and -not $Script:SysInfoJob) {
            $Script:Timer.Stop()
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
    if ($Script:SysInfoJob) {
        Stop-Job $Script:SysInfoJob -Force -ErrorAction SilentlyContinue
        Remove-Job $Script:SysInfoJob -Force -ErrorAction SilentlyContinue
    }
    if ($Script:ListJob) {
        Stop-Job $Script:ListJob -Force -ErrorAction SilentlyContinue
        Remove-Job $Script:ListJob -Force -ErrorAction SilentlyContinue
    }
})

# Mostrar ventana
$window.ShowDialog() | Out-Null

