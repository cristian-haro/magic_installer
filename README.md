# Magic Installer

<p align="center">
  <strong>Automated Batch Application Installer for Windows (Ninite Alternative)</strong><br>
  <em>Instalador desatendido de aplicaciones por lotes para Windows con interfaz grafica moderna</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Powered%20by-PowerShell%20%26%20Winget-5391FE?logo=powershell&logoColor=white" alt="PowerShell & Winget" />
  <img src="https://img.shields.io/badge/UI-WPF%20%2F%20XAML-512BD4" alt="UI" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
</p>

<p align="center">
  <img src="assets/screenshots/magic_installer_selection.png" alt="Magic Installer Selection View" width="850" />
</p>

---

## Language / Idioma
- [Espanol](#espanol)
- [English](#english)

---

## Espanol

### Descripcion
**Magic Installer** es una herramienta ligera y de codigo abierto para Windows inspirada en *Ninite*. Permite gestionar aplicaciones mediante una interfaz grafica nativa moderna (WPF) en dos modos principales:
1. **Instalador por Lotes:** Seleccionar multiples programas populares organizados por categorias e instalarlos todos en lote de forma **100% silenciosa, automatica y desatendida** con **Microsoft Winget**.
2. **Desinstalador por Lotes:** Escanear el software presente en el equipo y eliminar multiples programas seleccionados de forma masiva y limpia con un solo clic.

Sin barras de publicidad, sin instaladores basura (bloatware) y **siempre descargando la version mas reciente oficial** de cada programa directamente desde los servidores de los desarrolladores.

### Capturas de Pantalla

#### 1. Modo Instalador y Buscador en Tiempo Real
Permite filtrar rapidamente cualquier programa, marcar casillas, detectar aplicaciones ya instaladas y recibir notificaciones de actualizaciones disponibles.

<p align="center">
  <img src="assets/screenshots/magic_installer_selection.png" alt="Vista de Seleccion" width="850" />
</p>

#### 2. Modo Desinstalador por Lotes
Lista todos los programas instalados en el equipo y permite seleccionarlos y desinstalarlos masivamente de forma desatendida.

<p align="center">
  <img src="assets/screenshots/magic_installer_uninstaller.png" alt="Vista de Desinstalador" width="850" />
</p>

#### 3. Monitoreo del Progreso en Vivo
Muestra una barra de progreso animada y el estado individual de instalacion, actualizacion o desinstalacion en tiempo real.

<p align="center">
  <img src="assets/screenshots/magic_installer_progress.png" alt="Vista de Progreso" width="850" />
</p>

### Caracteristicas Clave
* **Doble Modo (Instalador & Desinstalador):** Cambia con un clic entre instalar paquetes nuevos y desinstalar aplicaciones existentes en lote.
* **Desinstalador por Lotes (Bulk Uninstaller):** Escanea el software instalado en el sistema, filtra dependencias internas y desinstala programas de forma silenciosa con confirmacion de seguridad.
* **Comprobacion Automatica de Actualizaciones:** Al iniciar, escanea de forma asincrona en segundo plano si hay programas instalados en el sistema desactualizados y muestra un banner verde superior para actualizar todo con un solo clic y monitoreo detallado.
* **Interfaz Grafica Nativa (WPF / XAML):** Ventana visual moderna con casillas de verificacion (`CheckBoxes`) organizadas por categorias.
* **Buscador en Tiempo Real:** Filtra instantaneamente cualquier aplicacion o categoria escribiendo en la barra superior.
* **Deteccion Inteligente de Programas Instalados:** Escanea el sistema y resalta con una etiqueta `[Instalado]` los programas ya presentes en tu equipo.
* **Ejecucion Standalone y Silenciosa:** Se puede ejecutar mediante el lanzador [`Magic_Installer.bat`](Magic_Installer.bat) o mediante el ejecutable compilado `Magic_Installer.exe` sin ventanas de consola visibles (`-WindowStyle Hidden`).
* **Instalacion Desatendida:** Automatiza la aceptacion de licencias y acuerdos mediante `winget`.
* **Siempre Actualizado:** Sincroniza fuentes antes de cada ejecucion para garantizar la ultima version estable.
* **Monitoreo en Tiempo Real:** Vista de progreso con barra animada y estados en vivo (*En espera*, *Procesando*, *Completado*).

### Estructura del Proyecto
```text
magic_installer/
│
├── Magic_Installer.bat       <-- Lanzador principal para el usuario (1 clic)
│
├── assets/                   <-- Recursos graficos y capturas de pantalla
│   └── screenshots/
│
├── src/                      <-- Codigo fuente
│   └── Magic_Installer.ps1
│
├── build/                    <-- Scripts de compilacion a ejecutable (.exe)
│   ├── build.ps1
│   ├── build.bat
│   └── capture.ps1
│
├── .github/                  <-- CI/CD Workflows para Releases
│   └── workflows/
│       └── release.yml
│
├── .gitignore
├── LICENSE
└── README.md
```

### Catalogo de Aplicaciones Incluidas

| Categoria | Aplicaciones Incluidas |
| :--- | :--- |
| **Navegadores** | Google Chrome, Mozilla Firefox, Brave Browser, Opera GX, Microsoft Edge, Vivaldi, Tor Browser |
| **Mensajeria y Comunicacion** | Mozilla Thunderbird, Asana, Discord, Telegram Desktop, WhatsApp, Zoom, Microsoft Teams, Slack |
| **Multimedia y Diseno** | Figma, VLC Media Player, Spotify, OBS Studio, Audacity, HandBrake, GIMP, Paint.NET, Blender, K-Lite Codec Pack |
| **Almacenamiento en la Nube** | Google Drive, Microsoft OneDrive, Dropbox, SugarSync |
| **Utilidades del Sistema** | 7-Zip, WinRAR, Transmission, qBittorrent, TeamViewer, AnyDesk, Glary Utilities, CCleaner, AutoHotkey, Microsoft PowerToys, Everything, TreeSize Free, CrystalDiskInfo, CPU-Z, GPU-Z, Rufus |
| **Desarrollo y Programacion** | Visual Studio Code, Cursor, Claude Desktop, Antigravity, Codex CLI, Git, Python 3, Android Studio, Eclipse IDE, Docker Desktop, WinSCP / FTP, GitHub Desktop, Notepad++, Node.js LTS, Postman, Windows Terminal, DBeaver |
| **Gaming y Tiendas** | Steam, Epic Games Launcher, GOG Galaxy, EA App |
| **Seguridad y Contrasenas** | Bitwarden, KeePassXC, Malwarebytes |

### Requisitos y Uso Rapido
1. **Requisitos:** Windows 10 (version 1809 o superior) o Windows 11 con **App Installer / Winget** habilitado (incluido por defecto en Windows).
2. **Uso:**
   * Descarga la ultima version desde la seccion de **Releases** o clona el repositorio:
     ```bash
     git clone https://github.com/cristian-haro/magic_installer.git
     ```
   * Ejecuta [`Magic_Installer.bat`](Magic_Installer.bat) o `Magic_Installer.exe`.
   * Selecciona los programas deseados (o usa el buscador para encontrarlos rapidamente).
   * Haz clic en **"Instalar Seleccionadas"** y observa el progreso en vivo.

### Compilacion a Ejecutable (.exe)
Para compilar un ejecutable independiente `Magic_Installer.exe` en la raiz del proyecto:
```bash
.\build\build.bat
```
Esto utilizara el compilador C# nativo de Windows (`csc.exe`) con manifiesto de administrador integrado.

---

## English

### Overview
**Magic Installer** is a lightweight, open-source Windows tool inspired by *Ninite*. It allows users to manage applications through a clean, modern native WPF graphical interface with two primary modes:
1. **Batch Installer Mode:** Select multiple popular applications organized by categories and install them silently and unattended using **Microsoft Winget**.
2. **Bulk Uninstaller Mode:** Scan installed system software and remove unwanted applications in bulk with a single click.

Zero toolbars, zero bloatware, and **always fetching the latest official release** directly from the vendors' servers.

### Screenshots

#### 1. Batch Installer Mode & Real-Time Search
Quickly filter programs, toggle category cards, view pre-installed tags, and receive update notifications.

<p align="center">
  <img src="assets/screenshots/magic_installer_selection.png" alt="Selection View" width="850" />
</p>

#### 2. Bulk Uninstaller Mode
Scans and lists installed programs, allowing fast multi-selection and silent removal.

<p align="center">
  <img src="assets/screenshots/magic_installer_uninstaller.png" alt="Uninstaller View" width="850" />
</p>

#### 3. Live Progress Tracker
Follow real-time installation, upgrade, or uninstallation stages with an animated progress bar and detailed badges.

<p align="center">
  <img src="assets/screenshots/magic_installer_progress.png" alt="Progress View" width="850" />
</p>

### Key Features
* **Dual Mode (Installer & Uninstaller):** Switch seamlessly between installing new tools and removing bloatware in bulk.
* **Bulk Uninstaller:** Scans installed software, filters out system packages, and uninstalls selected apps silently with safety confirmation prompts.
* **Automated System Update Detection:** Silently scans in the background on startup for outdated software installed across the system and presents an actionable green top banner to upgrade everything in one click with detailed live tracking.
* **Modern Native UI (WPF / XAML):** Clean desktop interface featuring direct checkboxes grouped into clear categories.
* **Real-Time Search & Filter:** Instantly filter any application or category as you type in the search bar.
* **Smart Installed Detection:** Automatically scans Windows and highlights previously installed programs with an `[Instalado]` badge.
* **Standalone & Hidden Execution:** Run directly through [`Magic_Installer.bat`](Magic_Installer.bat) or compile into a standalone `Magic_Installer.exe` executable without visible console windows (`-WindowStyle Hidden`).
* **Unattended Batch Installs:** Auto-accepts package agreements and licenses via `winget`.
* **Always Up-to-Date:** Synchronizes repository sources before every run to guarantee the newest available version.
* **Live Progress Tracking:** Integrated progress view with an animated progress bar and real-time status badges (*Queued*, *Processing*, *Completed*).

### Repository Structure
```text
magic_installer/
│
├── Magic_Installer.bat       <-- Main launcher for end users (1 click)
│
├── assets/                   <-- Screenshots and visual assets
│   └── screenshots/
│
├── src/                      <-- Source code
│   └── Magic_Installer.ps1
│
├── build/                    <-- Build scripts to generate standalone .exe
│   ├── build.ps1
│   ├── build.bat
│   └── capture.ps1
│
├── .github/                  <-- GitHub Actions CI/CD workflows
│   └── workflows/
│       └── release.yml
│
├── .gitignore
├── LICENSE
└── README.md
```

### Included Software Catalog

| Category | Included Applications |
| :--- | :--- |
| **Web Browsers** | Google Chrome, Mozilla Firefox, Brave Browser, Opera GX, Microsoft Edge, Vivaldi, Tor Browser |
| **Messaging & Collaboration** | Mozilla Thunderbird, Asana, Discord, Telegram Desktop, WhatsApp, Zoom, Microsoft Teams, Slack |
| **Media & Design** | Figma, VLC Media Player, Spotify, OBS Studio, Audacity, HandBrake, GIMP, Paint.NET, Blender, K-Lite Codec Pack |
| **Cloud Storage** | Google Drive, Microsoft OneDrive, Dropbox, SugarSync |
| **System Utilities** | 7-Zip, WinRAR, Transmission, qBittorrent, TeamViewer, AnyDesk, Glary Utilities, CCleaner, AutoHotkey, Microsoft PowerToys, Everything, TreeSize Free, CrystalDiskInfo, CPU-Z, GPU-Z, Rufus |
| **Development & IDEs** | Visual Studio Code, Cursor, Claude Desktop, Antigravity, Codex CLI, Git, Python 3, Android Studio, Eclipse IDE, Docker Desktop, WinSCP / FTP, GitHub Desktop, Notepad++, Node.js LTS, Postman, Windows Terminal, DBeaver |
| **Gaming Launchers** | Steam, Epic Games Launcher, GOG Galaxy, EA App |
| **Security & Passwords** | Bitwarden, KeePassXC, Malwarebytes |

### Requirements & Quick Start
1. **Requirements:** Windows 10 (1809+) or Windows 11 with **App Installer / Winget** (pre-installed by default).
2. **How to run:**
   * Download the latest release from the **Releases** section or clone the repository:
     ```bash
     git clone https://github.com/cristian-haro/magic_installer.git
     ```
   * Run [`Magic_Installer.bat`](Magic_Installer.bat) or `Magic_Installer.exe`.
   * Check the boxes for the applications you want (or use the search bar to locate them).
   * Click **"Instalar Seleccionadas"** and enjoy the automated installation.

### Building Standalone Executable (.exe)
To compile a standalone `Magic_Installer.exe` file in the root directory:
```bash
.\build\build.bat
```
This uses Windows' native C# compiler (`csc.exe`) with an embedded UAC administrator manifest.

---

## License
This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

Developed by **[Cristian Haro](https://github.com/cristian-haro)**.
