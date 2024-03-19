#!/bin/bash

# Alter these to point to your Trelica Organization ID and the correct domain (app or eu)
OrgID="a12345bc678d9e0f12a345b6c7f89def"
Domain="app.trelica.com"
TrelicaBrowserHelperUrl="https://vendeqappfiles.blob.core.windows.net/public/browserxtn/TrelicaBrowserHelper.pkg"

# Paths to install to
CurrentUser=$(who | awk '/console/{print $1}')
AppScriptsFolder="/Users/$CurrentUser/Library/Application Scripts"
GroupContainersFolder="/Users/$CurrentUser/Library/Group Containers"
plistPath="$GroupContainersFolder/2MXR75AJYH.com.trelica.macgroup/Library/Application Support/Trelica/BrowserHelper.plist"
AliasPath="$GroupContainersFolder/2MXR75AJYH.com.trelica.macgroup/Library/Application Scripts/2MXR75AJYH.com.trelica.macgroup"

# Paths to various browsers...
ChromeBasePath="/Users/$CurrentUser/Library/Application Support/Google/Chrome"
EdgeBasePath="/Users/$CurrentUser/Library/Application Support/Microsoft Edge"
MozillaBasePath="/Users/$CurrentUser/Library/Application Support/Mozilla"
# ...and the manifests we want to write
ChromeManifestPath="$ChromeBasePath/NativeMessagingHosts/com.trelica.browser_helper.json"
EdgeManifestPath="$EdgeBasePath/NativeMessagingHosts/com.trelica.browser_helper.json"
MozillaManifestPath="$MozillaBasePath/NativeMessagingHosts/com.trelica.browser_helper.json"
 
# Create necessary folders in the current user's Library
mkdir -p "$AppScriptsFolder/2MXR75AJYH.com.trelica.macgroup"
cd "$GroupContainersFolder" || exit

mkdir -p "$GroupContainersFolder/2MXR75AJYH.com.trelica.macgroup" \
         "$GroupContainersFolder/2MXR75AJYH.com.trelica.macgroup/Library/Caches" \
         "$GroupContainersFolder/2MXR75AJYH.com.trelica.macgroup/Library/Preferences"

# Create an alias inside 'Application Scripts' folder
mkdir -p "$(dirname "$AliasPath")"
 # Delete existing alias if it exists
rm -f "$AliasPath" 
ln -s "$AppScriptsFolder/2MXR75AJYH.com.trelica.macgroup" "$AliasPath" 
echo "Folders and alias created"

# Emit the plist
mkdir -p "$(dirname "$plistPath")"
cat > "$plistPath" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Domain</key>
    <string>$Domain</string>
    <key>OrgId</key>
    <string>$OrgID</string>
</dict>
</plist>
EOF
echo "plist written"

sudo chown -R "$CurrentUser" "$GroupContainersFolder/2MXR75AJYH.com.trelica.macgroup"
 
# Write Chrome and Edge manifests
ChromiumManifestJson='{
    "name": "com.trelica.browser_helper",
    "description": "Trelica Browser Helper",
    "path": "/Users/'"$CurrentUser"'/Library/Group Containers/2MXR75AJYH.com.trelica.macgroup/Library/Application Support/Trelica/TrelicaBrowserHelper",
    "type": "stdio",
    "allowed_origins": [
        "chrome-extension://alhagkkmlflbnlckfifmlemhcmaaflon/",
        "chrome-extension://igjpcenkahclnlkcldhphacgmfilbefd/"
    ]
}'
if [ -d "$ChromeBasePath" ]; then
    mkdir -p "$(dirname "$ChromeManifestPath")"
    echo "$ChromiumManifestJson" > "$ChromeManifestPath"
    sudo chown -R "$CurrentUser" "$ChromeManifestPath"
    echo "Chrome manifest written"
else
    echo "Chrome not installed"
fi

if [ -d "$EdgeBasePath" ]; then
    mkdir -p "$(dirname "$EdgeManifestPath")"
    echo "$ChromiumManifestJson" > "$EdgeManifestPath"
    sudo chown -R "$CurrentUser" "$EdgeManifestPath"
    echo "Edge manifest written"
else
    echo "Edge not installed"
fi

# Write Firefox manifest
MozillaManifestJson='{
    "name": "com.trelica.browser_helper",
    "description": "Trelica Browser Helper",
    "path": "/Users/'"$CurrentUser"'/Library/Group Containers/2MXR75AJYH.com.trelica.macgroup/Library/Application Support/Trelica/TrelicaBrowserHelper",
    "type": "stdio",
    "allowed_extensions": [
        browserextension@trelica.com
    ]
}'
if [ -d "$MozillaBasePath" ]; then
    mkdir -p "$(dirname "$MozillaManifestPath")"
    echo "$MozillaManifestJson" > "$MozillaManifestPath"
    sudo chown -R "$CurrentUser" "$MozillaManifestPath"
    echo "Mozilla manifest written"
else
    echo "Mozilla not installed"
fi
 
# Install Trelica Browser Helper
cd "/Users/$CurrentUser"
curl -O "$TrelicaBrowserHelperUrl"
sudo installer -pkg TrelicaBrowserHelper.pkg -target /Applications
rm TrelicaBrowserHelper.pkg