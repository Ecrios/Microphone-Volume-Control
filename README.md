<h1 align="center"> 🎙️ Microphone Volume & Fade Control (AHK v2) </h1>
<p align="center"> <img width="292" height="78" alt="image" src="https://github.com/user-attachments/assets/cd9b164e-01f8-445b-ba0f-1a7c5c16b43f" /> </p>

[Читать на русском](README.ru.md) | **English**

$\color{red}{\text{This program was created entirely using AI (Gemini 3.5 Flash, Gemini 3.1 Pro Preview, Gemini 3.6 Flash).}}$

An advanced microphone volume control utility written in **AutoHotkey v2**. It allows you to adjust volume or mute your microphone by moving the cursor to any screen corner, set precise volume levels instantly, or smoothly fade volume using global hotkeys.

![AHK v2](https://img.shields.io/badge/AutoHotkey-v2.0+-green.svg)
![Platform](https://img.shields.io/badge/Platform-Windows-blue.svg)
![License](https://img.shields.io/badge/License-MIT-brightgreen.svg)

---

## ✨ Features

- **📐 Screen Corner Hot-Zones:** Adjust volume or toggle mute seamlessly when hovering over a configured screen corner.
- **⚡ Instant Level Hotkeys:** Set exact volume levels (10% to 100%) globally using `Right Alt` + `1..0`.
- **🌊 Smooth Volume Fading:** Smoothly transition volume over 1.5 seconds using dedicated global hotkeys.
- **🖥️ Dynamic OSD (On-Screen Display):** Sleek overlay displaying current volume level, progress bar, and active state.
  - 🟢 **Green Bar:** Microphone is active.
  - 🔴 **Red Bar:** Microphone is muted.
- **🧠 Smart Overlay Hiding:** Automatically hides the OSD when leaving the corner, finishing fade animation, or after 1.5s of inactivity.
- **⚙️ Tray Customization & Audio Scanning:** Auto-detects microphones or lets you select a specific input device, active corner, and volume step.
- **💾 Persistent Settings:** Saves configuration automatically to `settings.ini`.

---

## ⌨️ Hotkeys & Controls

### 1. Screen Corner Controls
*(Active only when mouse cursor is placed in the designated corner)*

| Shortcut | Action |
| :--- | :--- |
| `Wheel Up` | Increase volume by configured step |
| `Wheel Down` | Decrease volume by configured step |
| `Middle Click` | Toggle Microphone Mute on / off |

---

### 2. Global Hotkeys (Strictly Right Alt)

#### 🎯 Direct Volume Preset
Set microphone volume instantly from anywhere:

| Hotkey | Action |
| :--- | :--- |
| `Right Alt` + `1` … `9` | Set volume instantly to **10% … 90%** |
| `Right Alt` + `0` | Set volume instantly to **100%** |

#### 🌊 Smooth Volume Transition (1.5s Fade)
Transitions current volume to target level smoothly over 1000ms:

| Hotkey | Target Volume | Key Reference |
| :--- | :---: | :--- |
| `Right Alt` + `,` | **10%** | `vkBC` (Comma / Letter Б) |
| `Right Alt` + `.` | **25%** | `vkBE` (Dot / Letter Ю) |
| `Right Alt` + `/` | **75%** | `vkBF` (Slash / Russian Dot) |

---

## ⚙️ Tray Menu & Configuration

Right-click the script icon in the **System Tray** to access:
- **Microphone Selection:** Choose `Auto (Default)` or pin a specific input device.
- **Active Corner:** Switch between `Top-Left`, `Top-Right`, `Bottom-Left`, and `Bottom-Right`.
- **Volume Step:** Set scroll step percentage (5%, 10%, 20%, 30%, 40%, 50%).
- **Refresh Device List:** Rescan audio input hardware without restarting the script.

---

## 📥 Installation & Usage

### Prerequisites
1. Download and install **[AutoHotkey v2.0](https://www.autohotkey.com/)** or newer.

### Getting Started
1. Download or clone this repository.
2. Run `main.ahk` (or script file) by double-clicking it.
3. The script will automatically create `settings.ini` in its directory to save your preferences.

---

## 📁 Project Structure

- `main.ahk` — Main AutoHotkey v2 script logic.
- `settings.ini` — Stores chosen microphone, corner, and volume step (generated automatically).

---

## 📄 License

This project is released under the [MIT License](LICENSE).
