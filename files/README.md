# 📁 File Organizer — Interactive Copy / Move Utility

![Bash](https://img.shields.io/badge/Shell-Bash-green?style=flat-square&logo=gnubash)
![Platform](https://img.shields.io/badge/Platform-Linux-blue?style=flat-square&logo=linux)
![License](https://img.shields.io/badge/License-MIT-yellow?style=flat-square)
![Version](https://img.shields.io/badge/Version-1.0-cyan?style=flat-square)
![Safe](https://img.shields.io/badge/Zero%20Deletions-✔-brightgreen?style=flat-square)

A clean, interactive command-line utility for organizing files by type — with built-in safety rails, sudo support, and a full confirmation gate before anything touches your filesystem.

Built as part of a personal IT Administration & Blue Team portfolio by **Gypsy-82**.

---

## ✨ Features

- 🎯 **Interactive CLI** — guided step-by-step prompts, no flags to memorize
- 📂 **Multi file-type targeting** — Audio, Video, Images, Documents, Archives, or custom extensions
- 🔁 **Copy or Move** — your choice, with clear warnings on Move operations
- 🔐 **Sudo mode** — elevated access for system paths, restricted to **Copy only**
- 🚫 **Protected path blacklist** — `/boot`, `/etc`, `/proc`, `/sys` and more can never be a destination
- 🔍 **Duplicate detection** — existing files at the destination are skipped, never overwritten
- 📁 **Create destination on the fly** — option to create a new directory if it doesn't exist
- 🔄 **Recursive or flat scan** — your choice per run
- 🛡️ **Symlink safe** — symlinks are never followed or processed
- ⌨️ **Ctrl+C safe** — clean exit at any point, no partial state left behind
- 🎨 **Color-coded output** — green/yellow/red/cyan feedback throughout

---

## 🔒 Safety Design

This script was built with a strict safety-first philosophy:

| Rule | Status |
|------|--------|
| No `rm` / delete operations | ✅ Enforced |
| No network calls | ✅ Enforced |
| No eval or code injection | ✅ Enforced |
| Sudo restricted to Copy only | ✅ Enforced |
| Protected system paths blocked as destination | ✅ Enforced |
| No silent overwrites | ✅ Enforced |
| Full confirmation before execution | ✅ Enforced |

---

## 🚀 Usage

```bash
chmod +x file_organizer.sh
./file_organizer.sh
```

No arguments required. The script will guide you through each step interactively.

---

## 🗂️ Supported File Types

| Category | Extensions |
|----------|------------|
| Audio | mp3 wav flac ogg aac |
| Video | mp4 mkv avi mov wmv |
| Images | png jpg jpeg gif webp bmp |
| Documents | txt pdf docx odt md |
| Archives | zip tar gz 7z rar |
| Custom | Any extension you specify |

---

## 🖥️ Script Flow

```
STEP 1 — Source Path        Enter and validate the source directory
STEP 2 — File Types         Select one or more file type categories
STEP 3 — Search Depth       Flat or recursive directory scan
STEP 4 — Operation          Copy or Move (sudo mode locks to Copy)
STEP 5 — Destination Path   Enter or create the destination directory
STEP 6 — Scan & Preview     Files found, sizes shown, duplicates flagged
STEP 7 — Full Summary       Review everything before committing
         └── Confirm gate   y to proceed, n to abort safely
         Execute            Per-file feedback during operation
         Final Report       Success / failed / skipped counts
```

---

## ⚙️ Requirements

- Bash 4.0+
- Standard GNU coreutils (`find`, `cp`, `mv`, `mkdir`, `du`)
- No external dependencies

---

## 📄 License

MIT — see [LICENSE](LICENSE) for details.

---

> Part of the **Gypsy-82** IT Administration & Linux Security toolkit.
