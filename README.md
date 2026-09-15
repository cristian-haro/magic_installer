# 🪄 Magic Installer

<p align="center">
  <strong>Automated Batch Application Installer for Windows (Ninite Alternative)</strong><br>
  <em>Instalador desatendido de aplicaciones por lotes para Windows con interfaz gráfica moderna</em>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Platform-Windows%2010%20%7C%2011-0078D6?logo=windows&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Powered%20by-PowerShell%20%26%20Winget-5391FE?logo=powershell&logoColor=white" alt="PowerShell & Winget" />
  <img src="https://img.shields.io/badge/UI-WPF%20%2F%20XAML-512BD4" alt="UI" />
  <img src="https://img.shields.io/badge/License-MIT-green.svg" alt="License" />
</p>

---

## 🌐 Language / Idioma
- [Español](#-español)
- [English](#-english)

---

## 🇪🇸 Español

### 📖 Descripción
**Magic Installer** es una herramienta ligera y de código abierto para Windows inspirada en *Ninite*. Permite seleccionar múltiples programas populares mediante una interfaz gráfica nativa moderna (WPF) con casillas de verificación e instalarlos todos en lote de forma **100% silenciosa, automática y desatendida** utilizando el gestor oficial de paquetes **Microsoft Winget**.

Sin barras de publicidad, sin instaladores basura (bloatware) y **siempre descargando la versión más reciente oficial** de cada programa directamente desde los servidores de los desarrolladores.

### ✨ Características Clave
* 🖥️ **Interfaz Gráfica Nativa (WPF / XAML):** Ventana visual moderna con casillas de verificación (`CheckBoxes`) organizadas por categorías.
* 🤫 **Ejecución Silenciosa y Oculta:** Sin ventanas de consola molestas de fondo (`-WindowStyle Hidden`).
* ⚡ **Instalación Desatendida:** Automatiza la aceptación de licencias y acuerdos mediante `winget`.
* 🔄 **Siempre Actualizado:** Sincroniza fuentes antes de cada ejecución para garantizar la última versión estable.
* 📊 **Monitoreo en Tiempo Real:** Vista de progreso con barra animada y estados en vivo (*En espera*, *Instalando*, *Completado*).
* 🛠️ **Fácilmente Extensible:** Añade tus propias aplicaciones favoritas editando una simple línea en el catálogo.

### 📦 Catálogo de Aplicaciones Incluidas
* **Navegadores:** Google Chrome, Mozilla Firefox, Brave, Opera GX, Microsoft Edge, Vivaldi, Tor Browser.
* **Mensajería y Comunicación:** Thunderbird, Asana, Discord, Telegram Desktop, WhatsApp, Zoom, Teams, Slack.
* **Multimedia y Diseño:** Figma, VLC, Spotify, OBS Studio, Audacity, HandBrake, GIMP, Paint.NET, Blender, K-Lite Codec Pack.
* **Almacenamiento en la Nube:** Google Drive, OneDrive, Dropbox, SugarSync.
* **Utilidades del Sistema:** 7-Zip, WinRAR, Transmission, qBittorrent, TeamViewer, AnyDesk, Glary Utilities, CCleaner, AutoHotkey, PowerToys, Everything, TreeSize Free, CrystalDiskInfo, CPU-Z, GPU-Z, Rufus.
* **Desarrollo y Programación:** Visual Studio Code, Cursor, Claude Desktop, Antigravity, Codex CLI, Git, Python 3, Android Studio, Eclipse IDE, Docker Desktop, WinSCP, GitHub Desktop, Notepad++, Node.js LTS, Postman, Windows Terminal, DBeaver.
* **Gaming:** Steam, Epic Games, GOG Galaxy, EA App.
* **Seguridad:** Bitwarden, KeePassXC, Malwarebytes.

### 🚀 Requisitos y Uso Rápido
1. **Requisitos:** Windows 10 (versión 1809 o superior) o Windows 11 con **App Installer / Winget** habilitado (incluido por defecto en Windows).
2. **Uso:**
   * Clona este repositorio o descarga el código:
     ```bash
     git clone https://github.com/cristian-haro/magic_installer.git
     ```
   * Haz doble clic sobre [`Magic_Installer.bat`](Magic_Installer.bat).
   * Marca las casillas de los programas deseados.
   * Haz clic en **"Instalar Seleccionadas"** y observa el progreso en vivo.

### ⚙️ Cómo Añadir Más Programas
Abre [`Magic_Installer.ps1`](Magic_Installer.ps1) y añade una nueva línea al array `$Apps`:
```powershell
[PSCustomObject]@{ Categoria = "Navegadores"; Nombre = "Tu Programa"; Id = "Empresa.TuPrograma"; Descripcion = "Breve descripción" }
```
*(Puedes buscar el ID oficial de cualquier programa en tu consola ejecutando `winget search NombrePrograma`).*

---

## 🇬🇧 English

### 📖 Overview
**Magic Installer** is a lightweight, open-source Windows tool inspired by *Ninite*. It allows users to select multiple popular software packages through a clean, modern native WPF graphical interface with checkboxes, installing them in bulk **silently, automatically, and unattended** using the official **Microsoft Winget** package manager.

Zero toolbars, zero bloatware, and **always fetching the latest official release** directly from the vendors' servers.

### ✨ Key Features
* 🖥️ **Modern Native UI (WPF / XAML):** Clean desktop interface featuring direct checkboxes grouped into clear categories.
* 🤫 **Hidden Console Execution:** No distracting command prompt or PowerShell background windows (`-WindowStyle Hidden`).
* ⚡ **Unattended Batch Installs:** Auto-accepts package agreements and licenses via `winget`.
* 🔄 **Always Up-to-Date:** Synchronizes repository sources before every run to guarantee the newest available version.
* 📊 **Live Progress Tracking:** Integrated progress view with an animated progress bar and real-time status badges (*Queued*, *Installing*, *Completed*).
* 🛠️ **Easily Extensible:** Add any custom app in seconds by inserting a single entry into the catalog array.

### 📦 Included Software Catalog
* **Web Browsers:** Google Chrome, Mozilla Firefox, Brave, Opera GX, Microsoft Edge, Vivaldi, Tor Browser.
* **Messaging & Collaboration:** Thunderbird, Asana, Discord, Telegram Desktop, WhatsApp, Zoom, Teams, Slack.
* **Media & Design:** Figma, VLC, Spotify, OBS Studio, Audacity, HandBrake, GIMP, Paint.NET, Blender, K-Lite Codec Pack.
* **Cloud Storage:** Google Drive, OneDrive, Dropbox, SugarSync.
* **System Utilities:** 7-Zip, WinRAR, Transmission, qBittorrent, TeamViewer, AnyDesk, Glary Utilities, CCleaner, AutoHotkey, PowerToys, Everything, TreeSize Free, CrystalDiskInfo, CPU-Z, GPU-Z, Rufus.
* **Development & IDEs:** Visual Studio Code, Cursor, Claude Desktop, Antigravity, Codex CLI, Git, Python 3, Android Studio, Eclipse IDE, Docker Desktop, WinSCP, GitHub Desktop, Notepad++, Node.js LTS, Postman, Windows Terminal, DBeaver.
* **Gaming Launchers:** Steam, Epic Games, GOG Galaxy, EA App.
* **Security & Passwords:** Bitwarden, KeePassXC, Malwarebytes.

### 🚀 Requirements & Quick Start
1. **Requirements:** Windows 10 (1809+) or Windows 11 with **App Installer / Winget** (pre-installed by default).
2. **How to run:**
   * Clone this repository or download the source:
     ```bash
     git clone https://github.com/cristian-haro/magic_installer.git
     ```
   * Double-click [`Magic_Installer.bat`](Magic_Installer.bat).
   * Check the boxes for the applications you want.
   * Click **"Instalar Seleccionadas"** and enjoy the automated installation.

### ⚙️ How to Add Custom Applications
Edit [`Magic_Installer.ps1`](Magic_Installer.ps1) and insert a new object in the `$Apps` list:
```powershell
[PSCustomObject]@{ Categoria = "Browsers"; Nombre = "Your App"; Id = "Vendor.YourApp"; Descripcion = "Short description" }
```
*(Find any application's Winget ID by running `winget search AppName` in your terminal).*

---

## 📄 License
This project is licensed under the [MIT License](LICENSE) - see the LICENSE file for details.

Developed with ❤️ by **[Cristian Haro](https://github.com/cristian-haro)**.
