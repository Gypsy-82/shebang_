# shebang_ — Unix Shell Utilities for System Administration

A collection of production-safe shell utilities built for Linux system administrators.
Every script is interactive, non-destructive by default, and built with containment first.

---

## Tools

### `file_organizer.sh` — Interactive Copy / Move Utility

A safe, interactive file management utility for Unix systems.

**Principles:**
- Zero destructive action without explicit confirmation
- Protected system paths blocked at the boundary — `/boot`, `/etc`, `/sys`, `/proc`, `/dev` and core binaries are hardcoded off-limits
- Sudo is requested only when required — never assumed
- Ctrl+C exits cleanly at any point with no side effects

**Usage:**
```bash
chmod +x files/file_organizer.sh
./files/file_organizer.sh
```

The tool walks you through source, destination, and operation (copy or move) interactively. No flags. No config. No guessing.

---

## Standards

All scripts in this repo follow the same rules:

| Rule | Implementation |
|---|---|
| No silent failures | Every operation confirmed and reported |
| Least privilege | Sudo only when the filesystem requires it |
| Protected paths | System directories hardcoded as off-limits |
| Clean exit | Ctrl+C trapped — no partial operations left behind |
| No external dependencies | stdlib only — works on any standard Linux install |

---

## Platform

Tested on Ubuntu 24.04, Debian 12, Kali Linux, Arch Linux.
Requires Bash 4.0+.

---

## License

MIT
