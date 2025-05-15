#!/bin/sh
set -euo pipefail

log() {
    echo "[INFO] $1"
}

warn() {
    echo "[WARN] $1" >&2
}

remove_if_empty() {
    local dir="$1"
    if [ -d "$dir" ] && [ -z "$(ls -A "$dir")" ]; then
        sudo rmdir "$dir" && log "Removed empty directory: $dir"
    else
        log "Skipped directory (not empty): $dir"
    fi
}

# ---- Constants ----

HELPER_NAME="TrelicaBrowserHelper"
CONFIG_FILE_NAME="BrowserHelper.plist"
GLOBAL_TRELICA_DIR="/Library/Trelica"
HELPER_DEST="$GLOBAL_TRELICA_DIR/$HELPER_NAME"
CONFIG_PATH="$GLOBAL_TRELICA_DIR/$CONFIG_FILE_NAME"
GROUP_CONTAINER_PATH="$HOME/Library/Group Containers/2MXR75AJYH.com.trelica.macgroup"
GROUP_CONTAINER_CONFIG_FILE="$GROUP_CONTAINER_PATH/Library/Application Support/Trelica/BrowserHelper.plist"

CHROME_DIR="/Library/Google/Chrome/NativeMessagingHosts"
EDGE_DIR="/Library/Microsoft Edge/NativeMessagingHosts"
FIREFOX_DIR="/Library/Application Support/Mozilla/NativeMessagingHosts"

OUTPUT_MANIFEST_NAME="com.trelica.browser_helper.json"

# ---- Removal process ----

# Remove helper binary
if [ -f "$HELPER_DEST" ]; then
    sudo rm -f "$HELPER_DEST" && log "Removed helper binary: $HELPER_DEST"
fi

# Remove config file
if [ -f "$CONFIG_PATH" ]; then
    sudo rm -f "$CONFIG_PATH" && log "Removed config file: $CONFIG_PATH"
fi

# Remove group container config file
if [ -f "$GROUP_CONTAINER_CONFIG_FILE" ]; then
    sudo rm -f "$GROUP_CONTAINER_CONFIG_FILE" && log "Removed group container config file: $GROUP_CONTAINER_CONFIG_FILE"
fi

# Remove group container
remove_if_empty "$GROUP_CONTAINER_PATH"

# Remove global Trelica dir if empty
remove_if_empty "$GLOBAL_TRELICA_DIR"

# Remove manifest files
for DIR in "$CHROME_DIR" "$EDGE_DIR" "$FIREFOX_DIR"; do
    TARGET="$DIR/$OUTPUT_MANIFEST_NAME"
    if [ -f "$TARGET" ]; then
        sudo rm -f "$TARGET" && log "Removed manifest: $TARGET"
    fi
    remove_if_empty "$DIR"
done
