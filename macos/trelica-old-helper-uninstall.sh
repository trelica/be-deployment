#!/bin/bash
set -euo pipefail

log()   { echo "[INFO] $1"; }
warn()  { echo "[WARN] $1" >&2; }

# List of files to remove
# We leave the BrowserHelper.plist as it is still valid for Safari
files=(
  "$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts/com.trelica.browser_helper.json"
  "$HOME/Library/Application Support/Mozilla/NativeMessagingHosts/com.trelica.browser_helper.json"
  "$HOME/Library/Application Support/Microsoft/Edge/NativeMessagingHosts/com.trelica.browser_helper.json"
  "$HOME/Library/Group Containers/2MXR75AJYH.com.trelica.macgroup/Library/Application Support/Trelica/TrelicaBrowserHelper"
)

# Remove each file if it exists
for f in "${files[@]}"; do
  if [ -f "$f" ]; then
    log "Removing $f"
    rm -f "$f"
  else
    log "File not found (skipping): $f"
  fi
done

# Attempt to remove the group container folder if it's empty
group_container="$HOME/Library/Group Containers/2MXR75AJYH.com.trelica.macgroup"

if [ -d "$group_container" ]; then
  if [ -z "$(find "$group_container" -type f)" ]; then
    log "Removing empty group container: $group_container"
    rm -rf "$group_container"
  else
    warn "Group container not empty, skipping: $group_container"
  fi
else
  log "Group container folder not found, skipping: $group_container"
fi