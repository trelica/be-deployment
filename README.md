# Trelica Browser Helper deployment

## Contents

-   [macOS](#macos)
-   [Windows](#windows)

## macOS

### Profiles

There are three profiles available for deployment:

-   `UNSIGNED_trelica-extensions.mobileconfig` - Force install Trelica browser extension for Chrome, Edge and Firefox
-   `trelica-extensions.mobileconfig` - signed version of the above
-   `UNSIGNED_trelica-helper.mobileconfig` - template for apply settings prior to deploying the Browser helper.

These are all referenced and described in the [Deploying on macOS](https://help.trelica.com/hc/en-us/articles/9946257398429-Deploying-on-macOS) Trelica help article.

### Editing profiles in iMazing

iMazing is a widely used profile editor and this can be used to edit and save signed profiles.

The `UNSIGNED_trelica-helper.mobileconfig` file won't show in iMazing without a custom manifest.

You can configure this as follows:

1. Download and install iMazing from https://imazing.com/profile-editor/download/macos
2. Open preferences with `⌘,`
3. Choose the _Manifests_ tab
4. Set _Local folder for custom and override preference manifests (optional)_ to `~/{YOUR PATH}/be-deployment/profile-manifests`

### Uninstalling the Browser Helper

There are some scripts for uninstalling the Browser Helper:

-   `trelica-helper-uninstall.sh` (1.3 onwards, system-level install)
-   `trelica-old-helper-uninstall.sh` (pre 1.3, user-specific install)

## Windows

### Set-ForceInstallBrowserExtensions

A PowerShell script that configures system registry settings to force-install the Trelica Browser Extension for Google Chrome, Microsoft Edge, and Mozilla Firefox on Windows.

-   Ensures admin privileges are enforced before making changes.
-   Creates or updates registry keys under the current user’s policy paths for Chrome and Edge to add the Trelica extension to their ExtensionInstallForcelist.
-   For Firefox, it sets the ExtensionSettings JSON object to force-install the extension from a specified URL.
-   Avoids duplicating existing extension entries and handles malformed JSON data gracefully.
