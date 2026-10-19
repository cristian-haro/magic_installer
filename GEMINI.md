# GEMINI.md - Magic Installer Project Instructions & Engineering Standards

> **Universal Operating Instructions for Antigravity, Gemini & Cursor Agents**  
> Enforces senior engineering rigor, strict zero-emoji standard, clean architecture, responsive web craft for landing assets, unattended batch automation with Microsoft Winget, and automated release packaging powered by the [Skills Suite](https://github.com/cristian-haro/skills).

---

## 1. Core Operating Philosophy & Non-Negotiables

### 1.1 Strict Zero-Emoji Standard
*Reference Skill:* [`design-and-tokens/zero-emoji-standard`](https://github.com/cristian-haro/skills/blob/main/design-and-tokens/zero-emoji-standard/SKILL.md)
* **Absolute Ban:** Emojis (Unicode emojis such as rockets, checkmarks, fire, sparkles, lightbulbs, lightning) are strictly forbidden across:
  * User Interfaces (WPF/XAML desktop views, buttons, status badges, web landing page).
  * Git commit messages and pull request titles/descriptions.
  * Test suites, build scripts, console outputs, and logs.
  * Code comments, markdown headers, and documentation.
* **Approved Alternatives:**
  * **Vector Icons & Native Glyphs:** Use Segoe MDL2 Assets (`FontFamily="Segoe MDL2 Assets"` in WPF) or standard SVG vector icons in web interfaces.
  * **Typographic & Semantic Indicators:** Use refined geometric symbols (`->`, `+`, `/`, `*`, `•`) or badge pills (`[Instalado]`, `[OK]`, `[ERROR]`).
  * **Semantic Color Tokens:** Use subtle borders, tinted backgrounds, and accent colors to denote status.

### 1.2 Anti-Generic Design & Native Windows Desktop Craft
*Reference Skill:* [`design-and-tokens/frontend-art-direction`](https://github.com/cristian-haro/skills/blob/main/design-and-tokens/frontend-art-direction/SKILL.md)
* The desktop application interface is built with native WPF/XAML following modern Windows dark mode aesthetics (tinted dark surfaces `#0a0f1d`, subtle border glows `#1f2f4c`, cyan accent `#38bdf8`, and clean typography).
* The web landing page (`index.html`) must follow dark/light mode standards, fluid clamp typography, and zero-emoji compliance.

---

## 2. Architecture & Code Quality Standards

### 2.1 Project Architecture & Packaging Pipeline
* **Single-File Execution Invariant:** The desktop application is designed to run standalone via `Magic_Installer.bat` or compiled to `Magic_Installer.exe` with zero external runtime dependencies beyond Windows native PowerShell and App Installer (`winget`).
* **Packaging Invariant:** The build script (`build/build.ps1`) compiles a standalone C# launcher wrapper (`csc.exe`) embedding the PowerShell script encoded in Base64 with an embedded UAC administrator manifest (`requireAdministrator`) and multi-resolution application icon (`assets/icon.ico`).
* **Modularization Guideline:** When decomposing or modularizing `src/Magic_Installer.ps1` into granular submodules (Catalog, UI XAML, Winget Service, Hardware Monitor, Uninstaller), always maintain a build pre-bundler step or self-contained distribution script to avoid breaking the standalone `.exe` execution model.
* **Granular File Decomposition:** Keep utility scripts, build tools, and helper components under 150-200 lines where feasible.

### 2.2 Security Hardening & Safe Execution
* **UAC Elevation:** The application requires administrator privileges to execute unattended package installations and uninstallations. It requests UAC elevation natively via manifest in the compiled binary or self-elevates invisibly with `Start-Process -Verb RunAs` in script mode.
* **Unattended Execution:** Winget calls must always specify non-interactive flags (`--accept-package-agreements --accept-source-agreements --silent`) to prevent hanging dialogs.
* **Destructive Action Confirmation:** The Bulk Uninstaller mode must always prompt the user with an explicit confirmation dialog before invoking uninstallation routines.

---

## 3. Git, Documentation & Release Standards

### 3.1 Conventional Commits v1.0.0
*Reference Skill:* [`tooling-and-devops/conventional-commits`](https://github.com/cristian-haro/skills/blob/main/tooling-and-devops/conventional-commits/SKILL.md)
* Format: `<type>(<scope>): <short description>`
* Allowed types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
* **Zero Emojis in Git:** Never prefix commits with emojis or gitmoji.

### 3.2 Unified Bilingual README
*Reference Skill:* [`workflow-and-content/bilingual-docs-and-readme-craft`](https://github.com/cristian-haro/skills/blob/main/workflow-and-content/bilingual-docs-and-readme-craft/SKILL.md)
* Maintain full synchronization between Spanish (`#espanol`) and English (`#english`) sections in `README.md`.
* Ensure that the repository structure tree in both sections accurately reflects all tracked files (including build scripts, landing page, and assets).

### 3.3 Automated CI/CD Release
* GitHub Actions workflow (`.github/workflows/release.yml`) compiles `Magic_Installer.exe` and packages `Magic_Installer_v*.zip` automatically upon pushing version tags (`v*`).

---

## 4. Pre-Commit Execution Checklist

Before completing any task, opening a PR, or releasing:

- [ ] **Strict Zero-Emoji Compliance:** No emojis exist in UI components, XAML, scripts, comments, docs, or git commits.
- [ ] **Native Glyphs & SVGs Exclusively:** All icons use Segoe MDL2 Assets in XAML or SVGs in HTML.
- [ ] **UAC & Execution Safety:** Scripts verify Administrator privileges cleanly without leaving orphan console windows.
- [ ] **Unattended Package Invariants:** Winget arguments include agreements and silent execution flags.
- [ ] **Bilingual README Accuracy:** File trees and catalog tables in `README.md` match repository contents.
- [ ] **Build Integrity:** Standalone build via `build/build.bat` succeeds and produces a functional executable without compiler warnings.
- [ ] **Conventional Commits v1.0.0:** Commit message strictly follows `<type>(<scope>): <description>` without emojis.
