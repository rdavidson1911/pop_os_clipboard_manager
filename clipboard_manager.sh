#!/bin/bash
# Summary: Clipboard Manager using simple interface, sqlite3 database and xclip with simulates
# The Windows + V functionalilty on Windows 11 devices
# Author: rpd
# Date: 2024-11-11
# Version: 0.1.1
# Tested on Ubuntu 22.04 LTS Pop_OS!
# =============================================================================================
# Configuration
CLIPBOARD_DIR="$HOME/.clipboard_history"
MAX_ENTRIES=25
DB_FILE="$CLIPBOARD_DIR/clipboard.db"
LOCK_FILE="$CLIPBOARD_DIR/clipboard.lock"

# Check and install dependencies
check_dependencies() {
    local deps=("zenity" "xclip" "sqlite3")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            zenity --question \
                --title="Missing Dependency" \
                --text="$dep is not installed. Would you like to install it?" \
                --width=300
            if [ $? -eq 0 ]; then
                if command -v apt &> /dev/null; then
                    sudo apt-get update && sudo apt-get install -y "$dep"
                elif command -v dnf &> /dev/null; then
                    sudo dnf install -y "$dep"
                elif command -v pacman &> /dev/null; then
                    sudo pacman -S --noconfirm "$dep"
                else
                    zenity --error --text="Could not install $dep. Please install it manually."
                    exit 1
                fi
            else
                exit 1
            fi
        fi
    done
}

# Initialize clipboard directory and database
init_clipboard() {
    mkdir -p "$CLIPBOARD_DIR"
    if [ ! -f "$DB_FILE" ]; then
        sqlite3 "$DB_FILE" <<EOF
CREATE TABLE clipboard (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    content TEXT NOT NULL,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
EOF
    fi
}

# Add new item to clipboard history
add_to_history() {
    local content="$1"
    # Escape single quotes for SQL
    content="${content//\'/\'\'}"
    
    # Add new entry
    sqlite3 "$DB_FILE" "INSERT INTO clipboard (content) VALUES ('$content');"
    
    # Keep only last MAX_ENTRIES
    sqlite3 "$DB_FILE" "DELETE FROM clipboard WHERE id NOT IN (SELECT id FROM clipboard ORDER BY timestamp DESC LIMIT $MAX_ENTRIES);"
}

# Monitor clipboard for changes
monitor_clipboard() {
    local previous_clipboard=""
    
    while true; do
        current_clipboard=$(xclip -selection clipboard -o 2>/dev/null)
        
        if [ "$current_clipboard" != "$previous_clipboard" ] && [ ! -z "$current_clipboard" ]; then
            # Use flock to prevent race conditions
            (
                flock -x 200
                add_to_history "$current_clipboard"
            ) 200>$LOCK_FILE
            previous_clipboard="$current_clipboard"
        fi
        sleep 0.5
    done
}

# Show clipboard history GUI
show_history() {
    # Get entries from database
    local entries=$(sqlite3 "$DB_FILE" "SELECT content, datetime(timestamp, 'localtime') FROM clipboard ORDER BY timestamp DESC;")
    
    if [ -z "$entries" ]; then
        zenity --info --text="No clipboard history available." --width=300
        return
    fi
    
    # Create array of entries for zenity list
    local items=()
    while IFS='|' read -r content timestamp; do
        items+=("[$timestamp] $content")
    done < <(echo "$entries")
    
    # Show selection dialog using array
    selected=$(zenity --list \
        --title="Clipboard History" \
        --text="Select an item to copy:" \
        --column="Content" \
        "${items[@]}" \
        --width=800 \
        --height=600)
    
    if [ ! -z "$selected" ]; then
        # Extract content without timestamp
        content=$(echo "$selected" | sed 's/\[[^]]*\] //')
        echo -n "$content" | xclip -selection clipboard
        zenity --info \
            --text="Copied to clipboard!" \
            --timeout=2
    fi
}

# Main
if [ "$1" = "--show-history" ]; then
    show_history
    exit 0
fi

check_dependencies
init_clipboard

# Start clipboard monitor in background
monitor_clipboard &
MONITOR_PID=$!

# Create system tray icon (if available)
if command -v yad &> /dev/null; then
    yad --notification \
        --image="edit-copy" \
        --text="Clipboard Manager" \
        --command="bash -c 'show_history'" &
    TRAY_PID=$!
fi

# Trap SIGTERM and SIGINT
trap 'kill $MONITOR_PID 2>/dev/null; kill $TRAY_PID 2>/dev/null; exit 0' TERM INT

# Main menu
while true; do
    action=$(zenity --list \
        --title="Clipboard Manager" \
        --text="Choose an action:" \
        --column="Action" \
        "Show Clipboard History" \
        "Clear History" \
        "Exit" \
        --width=300 \
        --height=250)
    
    case "$action" in
        "Show Clipboard History")
            show_history
            ;;
        "Clear History")
            zenity --question \
                --text="Are you sure you want to clear clipboard history?" \
                --width=300
            if [ $? -eq 0 ]; then
                sqlite3 "$DB_FILE" "DELETE FROM clipboard;"
                zenity --info \
                    --text="Clipboard history cleared!" \
                    --timeout=2
            fi
            ;;
        "Exit")
            kill $MONITOR_PID 2>/dev/null
            kill $TRAY_PID 2>/dev/null
            exit 0
            ;;
        *)
            exit 0
            ;;
    esac
done 