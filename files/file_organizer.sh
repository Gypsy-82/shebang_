#!/usr/bin/env bash
#  FILE ORGANIZER — Interactive Copy / Move Utility
#  Author  : Gypsy-82
#  Version : 1.0
#  License : MIT

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BLUE='\033[0;34m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

PROTECTED_PATHS=("/boot" "/etc" "/sys" "/proc" "/dev" "/run" "/bin" "/sbin" "/lib" "/usr/bin" "/usr/sbin")

trap ctrl_c INT
ctrl_c() {
    echo -e "\n${YELLOW}  [!] Interrupted by user. No files were modified. Exiting.${RESET}\n"
    exit 0
}

print_banner() {
    clear
    echo -e "${CYAN}${BOLD}"
    echo "  ╔══════════════════════════════════════════════════╗"
    echo "  ║           FILE ORGANIZER  v1.0                  ║"
    echo "  ║     Interactive Copy / Move Utility             ║"
    echo "  ╚══════════════════════════════════════════════════╝"
    echo -e "${RESET}"
    echo -e "${DIM}  Press Ctrl+C at any time to exit safely.${RESET}\n"
}

divider() {
    echo -e "${DIM}  ────────────────────────────────────────────────────${RESET}"
}

is_protected_path() {
    local target="$1"
    for p in "${PROTECTED_PATHS[@]}"; do
        if [[ "$target" == "$p" || "$target" == "$p/"* ]]; then
            return 0
        fi
    done
    return 1
}

needs_sudo() {
    local path="$1"
    if [[ -d "$path" ]]; then
        [[ ! -r "$path" ]] && return 0
    elif [[ -f "$path" ]]; then
        [[ ! -r "$path" ]] && return 0
    else
        parent=$(dirname "$path")
        [[ ! -w "$parent" ]] && return 0
    fi
    return 1
}

print_banner

echo -e "${BOLD}  STEP 1 — Source Path${RESET}"
divider
while true; do
    echo -e -n "${CYAN}  Enter the source directory to search: ${RESET}"
    read -r SOURCE_PATH
    SOURCE_PATH="${SOURCE_PATH/#\~/$HOME}"

    if [[ -z "$SOURCE_PATH" ]]; then
        echo -e "${RED}  [!] Path cannot be empty.${RESET}"
        continue
    fi

    if [[ ! -d "$SOURCE_PATH" ]]; then
        echo -e "${RED}  [!] Directory not found: $SOURCE_PATH${RESET}"
        continue
    fi

    echo -e "${GREEN}  [✓] Source found: $SOURCE_PATH${RESET}"
    break
done

USE_SUDO=false
if needs_sudo "$SOURCE_PATH"; then
    echo -e "\n${YELLOW}  [!] This path requires elevated permissions (sudo).${RESET}"
    echo -e "${YELLOW}      Note: MOVE will be DISABLED. Copy only for system paths.${RESET}"
    echo -e -n "${CYAN}  Proceed with sudo? (y/n): ${RESET}"
    read -r SUDO_CONFIRM
    if [[ "${SUDO_CONFIRM,,}" == "y" ]]; then
        USE_SUDO=true
        echo -e "${GREEN}  [✓] Sudo mode enabled — Copy ONLY.${RESET}"
    else
        echo -e "${YELLOW}  [!] Sudo declined. Exiting.${RESET}"
        exit 0
    fi
fi

echo ""

echo -e "${BOLD}  STEP 2 — File Types${RESET}"
divider
echo -e "  Select file types to target:\n"
echo -e "  ${CYAN}[1]${RESET} Audio        (mp3 wav flac ogg aac)"
echo -e "  ${CYAN}[2]${RESET} Video        (mp4 mkv avi mov wmv)"
echo -e "  ${CYAN}[3]${RESET} Images       (png jpg jpeg gif webp bmp)"
echo -e "  ${CYAN}[4]${RESET} Documents    (txt pdf docx odt md)"
echo -e "  ${CYAN}[5]${RESET} Archives     (zip tar gz 7z rar)"
echo -e "  ${CYAN}[6]${RESET} All of the above"
echo -e "  ${CYAN}[7]${RESET} Custom extension(s)\n"

echo -e -n "${CYAN}  Enter choice(s) separated by spaces (e.g. 1 3): ${RESET}"
read -r TYPE_INPUT

EXTENSIONS=()
for choice in $TYPE_INPUT; do
    case "$choice" in
        1) EXTENSIONS+=(mp3 wav flac ogg aac) ;;
        2) EXTENSIONS+=(mp4 mkv avi mov wmv) ;;
        3) EXTENSIONS+=(png jpg jpeg gif webp bmp) ;;
        4) EXTENSIONS+=(txt pdf docx odt md) ;;
        5) EXTENSIONS+=(zip tar gz 7z rar) ;;
        6) EXTENSIONS+=(mp3 wav flac ogg aac mp4 mkv avi mov wmv png jpg jpeg gif webp bmp txt pdf docx odt md zip tar gz 7z rar) ;;
        7)
            echo -e -n "${CYAN}  Enter extension(s) without dot, space-separated (e.g. sh py rb): ${RESET}"
            read -r CUSTOM_EXT
            for ext in $CUSTOM_EXT; do
                EXTENSIONS+=("$ext")
            done
            ;;
        *)
            echo -e "${YELLOW}  [!] Unknown option '$choice' — skipped.${RESET}"
            ;;
    esac
done

EXTENSIONS=($(echo "${EXTENSIONS[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '))

if [[ ${#EXTENSIONS[@]} -eq 0 ]]; then
    echo -e "${RED}  [!] No valid file types selected. Exiting.${RESET}"
    exit 1
fi

echo -e "${GREEN}  [✓] Targeting: ${EXTENSIONS[*]}${RESET}\n"

echo -e "${BOLD}  STEP 3 — Search Depth${RESET}"
divider
echo -e -n "${CYAN}  Search subdirectories recursively? (y/n): ${RESET}"
read -r RECURSE_INPUT
RECURSIVE=false
[[ "${RECURSE_INPUT,,}" == "y" ]] && RECURSIVE=true
echo -e "${GREEN}  [✓] Recursive: $RECURSIVE${RESET}\n"

echo -e "${BOLD}  STEP 4 — Operation${RESET}"
divider

if [[ "$USE_SUDO" == true ]]; then
    echo -e "${YELLOW}  [!] Sudo mode active — MOVE is disabled. Copy only.${RESET}"
    ACTION="copy"
    echo -e "${GREEN}  [✓] Action: COPY${RESET}\n"
else
    echo -e "  ${CYAN}[1]${RESET} Copy  ${DIM}(source files remain intact)${RESET}"
    echo -e "  ${CYAN}[2]${RESET} Move  ${DIM}(files leave the source directory)${RESET}\n"
    echo -e -n "${CYAN}  Enter choice (1 or 2): ${RESET}"
    read -r ACTION_INPUT

    case "$ACTION_INPUT" in
        1) ACTION="copy" ;;
        2) ACTION="move"
           echo -e "\n${YELLOW}  [!] WARNING: Move will remove files from the source.${RESET}"
           echo -e "${YELLOW}      Ensure you have confirmed the correct source path.${RESET}"
           ;;
        *)
            echo -e "${RED}  [!] Invalid selection. Exiting.${RESET}"
            exit 1
            ;;
    esac
    echo -e "${GREEN}  [✓] Action: ${ACTION^^}${RESET}\n"
fi

echo -e "${BOLD}  STEP 5 — Destination Path${RESET}"
divider
while true; do
    echo -e -n "${CYAN}  Enter the destination directory: ${RESET}"
    read -r DEST_PATH
    DEST_PATH="${DEST_PATH/#\~/$HOME}"

    if [[ -z "$DEST_PATH" ]]; then
        echo -e "${RED}  [!] Path cannot be empty.${RESET}"
        continue
    fi

    if is_protected_path "$DEST_PATH"; then
        echo -e "${RED}  [!] '$DEST_PATH' is a protected system path. Cannot write here.${RESET}"
        continue
    fi

    if [[ ! -d "$DEST_PATH" ]]; then
        echo -e "${YELLOW}  [!] Directory does not exist: $DEST_PATH${RESET}"
        echo -e -n "${CYAN}  Create it? (y/n): ${RESET}"
        read -r CREATE_CONFIRM
        if [[ "${CREATE_CONFIRM,,}" == "y" ]]; then
            mkdir -p "$DEST_PATH"
            if [[ $? -ne 0 ]]; then
                echo -e "${RED}  [!] Failed to create directory. Check permissions.${RESET}"
                continue
            fi
            echo -e "${GREEN}  [✓] Created: $DEST_PATH${RESET}"
        else
            echo -e "${YELLOW}  [!] Please enter a different path.${RESET}"
            continue
        fi
    fi

    if [[ ! -w "$DEST_PATH" ]]; then
        echo -e "${RED}  [!] No write permission for: $DEST_PATH${RESET}"
        continue
    fi

    echo -e "${GREEN}  [✓] Destination: $DEST_PATH${RESET}"
    break
done
echo ""

echo -e "${BOLD}  STEP 6 — Scanning...${RESET}"
divider

FOUND_FILES=()
for ext in "${EXTENSIONS[@]}"; do
    if [[ "$RECURSIVE" == true ]]; then
        while IFS= read -r -d '' f; do
            FOUND_FILES+=("$f")
        done < <(find "$SOURCE_PATH" -type f -iname "*.${ext}" ! -type l -print0 2>/dev/null)
    else
        while IFS= read -r -d '' f; do
            FOUND_FILES+=("$f")
        done < <(find "$SOURCE_PATH" -maxdepth 1 -type f -iname "*.${ext}" ! -type l -print0 2>/dev/null)
    fi
done

IFS=$'\n' FOUND_FILES=($(printf '%s\n' "${FOUND_FILES[@]}" | sort -u))
unset IFS

FILE_COUNT=${#FOUND_FILES[@]}

if [[ $FILE_COUNT -eq 0 ]]; then
    echo -e "${YELLOW}  [!] No matching files found in: $SOURCE_PATH${RESET}"
    echo -e "${YELLOW}      Nothing to do. Exiting.${RESET}\n"
    exit 0
fi

echo -e "${GREEN}  [✓] Found ${FILE_COUNT} file(s):${RESET}\n"
for f in "${FOUND_FILES[@]}"; do
    SIZE=$(du -sh "$f" 2>/dev/null | cut -f1)
    echo -e "  ${DIM}  ${SIZE}${RESET}  $(basename "$f")"
    echo -e "       ${DIM}↳ $f${RESET}"
done
echo ""

SKIP_FILES=()
PROCEED_FILES=()
for f in "${FOUND_FILES[@]}"; do
    fname=$(basename "$f")
    if [[ -e "${DEST_PATH}/${fname}" ]]; then
        SKIP_FILES+=("$fname")
    else
        PROCEED_FILES+=("$f")
    fi
done

if [[ ${#SKIP_FILES[@]} -gt 0 ]]; then
    echo -e "${YELLOW}  [!] ${#SKIP_FILES[@]} file(s) already exist at destination and will be SKIPPED:${RESET}"
    for s in "${SKIP_FILES[@]}"; do
        echo -e "  ${YELLOW}    → $s${RESET}"
    done
    echo ""
fi

echo -e "${BOLD}  STEP 7 — Summary${RESET}"
divider
echo -e "  ${BOLD}  Action      :${RESET} ${CYAN}${ACTION^^}${RESET}"
echo -e "  ${BOLD}  From        :${RESET} $SOURCE_PATH"
echo -e "  ${BOLD}  To          :${RESET} $DEST_PATH"
echo -e "  ${BOLD}  File Types  :${RESET} ${EXTENSIONS[*]}"
echo -e "  ${BOLD}  Recursive   :${RESET} $RECURSIVE"
echo -e "  ${BOLD}  Total Found :${RESET} $FILE_COUNT file(s)"
echo -e "  ${BOLD}  To Process  :${RESET} ${GREEN}${#PROCEED_FILES[@]} file(s)${RESET}"
echo -e "  ${BOLD}  To Skip     :${RESET} ${YELLOW}${#SKIP_FILES[@]} duplicate(s)${RESET}"
[[ "$USE_SUDO" == true ]] && echo -e "  ${BOLD}  Sudo Mode   :${RESET} ${YELLOW}ENABLED — Copy only${RESET}"
divider

if [[ ${#PROCEED_FILES[@]} -eq 0 ]]; then
    echo -e "${YELLOW}  [!] All files already exist at destination. Nothing to do.${RESET}\n"
    exit 0
fi

echo -e -n "\n${CYAN}  Proceed with ${ACTION^^}? (y/n): ${RESET}"
read -r FINAL_CONFIRM

if [[ "${FINAL_CONFIRM,,}" != "y" ]]; then
    echo -e "${YELLOW}\n  [!] Aborted by user. No files were modified.${RESET}\n"
    exit 0
fi

echo ""

echo -e "${BOLD}  Executing...${RESET}"
divider

SUCCESS_COUNT=0
FAIL_COUNT=0

for f in "${PROCEED_FILES[@]}"; do
    fname=$(basename "$f")
    dest_file="${DEST_PATH}/${fname}"

    if [[ "$USE_SUDO" == true ]]; then
        CMD="sudo cp"
    elif [[ "$ACTION" == "copy" ]]; then
        CMD="cp"
    else
        CMD="mv"
    fi

    $CMD "$f" "$dest_file" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        echo -e "  ${GREEN}[✓]${RESET} ${ACTION^^}: $fname"
        ((SUCCESS_COUNT++))
    else
        echo -e "  ${RED}[✗]${RESET} FAILED: $fname"
        ((FAIL_COUNT++))
    fi
done

echo ""
divider
echo -e "${BOLD}  COMPLETE${RESET}"
divider
echo -e "  ${GREEN}[✓] Success   : $SUCCESS_COUNT file(s)${RESET}"
[[ $FAIL_COUNT -gt 0 ]]       && echo -e "  ${RED}[✗] Failed    : $FAIL_COUNT file(s)${RESET}"
[[ ${#SKIP_FILES[@]} -gt 0 ]] && echo -e "  ${YELLOW}[!] Skipped   : ${#SKIP_FILES[@]} duplicate(s)${RESET}"
echo -e "  ${DIM}  Destination : $DEST_PATH${RESET}"
divider
echo ""
