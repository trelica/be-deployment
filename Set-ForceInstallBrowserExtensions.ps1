<#
    .SYNOPSIS
    This script updates the registry to force install the Trelica Browser Extension in Chrome, Edge and Firefox.

    .DESCRIPTION
    The script ensures the registry key for Google Chrome and Edge Extension Install policies exists and updates them.
    It performs a similar action for Firefox.

    .AUTHOR
    Trelica
#>

# stop on first error
$ErrorActionPreference = "Stop"

function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
    Write-Warning "You do not have Administrator rights to run this script!`nPlease run PowerShell as Administrator."
    Exit
}

function Add-ExtensionToRegistry {
    param (
        [string]$registryPath,
        [string]$extensionId
    )

    # Check if the registry key exists
    if (-Not (Test-Path $registryPath)) {
        # Create the registry key if it does not exist
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Get all the existing values under the registry key
    $values = Get-ItemProperty -Path $registryPath -ErrorAction SilentlyContinue

    # Initialize a variable to store the maximum index
    $maxIndex = 0

    # Iterate over each property to find the highest numeric name and check for duplicate data
    $duplicateFound = $false
    if ($values) {
        foreach ($value in $values.PSObject.Properties) {
            # Attempt to convert the name to an integer
            $currentValue = 0
            if ([int]::TryParse($value.Name, [ref]$currentValue)) {
                if ($currentValue -gt $maxIndex) {
                    $maxIndex = $currentValue
                }
            }

            # Check if the current value's data matches the data we want to add
            if ($value.Value -eq $extensionId) {
                $duplicateFound = $true
                break
            }
        }
    }
    # Add new value only if no duplicate was found
    if (-not $duplicateFound) {
        # Increment the maximum index by 1 for the new value name
        $newValueName = $maxIndex + 1

        # Create the new registry value
        New-ItemProperty -Path $registryPath -Name $newValueName -Value $extensionId -PropertyType String

        # Output the created value and name for confirmation
        Write-Output "Created new registry value '$newValueName' with data '$extensionId' at '$registryPath'"
    }
    else {
        Write-Output "Extension ID '$extensionId' already exists under '$registryPath'. No new entry added."
    }
}

function Update-FirefoxRegistryValue {
    param (
        [string]$registryPath
    )

    $extensionKey = "browserextension@trelica.com"
    $newData = @{
        installation_mode = "force_installed"
        install_url       = "https://addons.mozilla.org/firefox/downloads/file/4113298/trelica-latest.xpi"
    }

    # Check if the registry key exists
    if (-Not (Test-Path $registryPath)) {
        # Create the registry key if it does not exist
        New-Item -Path $registryPath -Force | Out-Null
    }

    # Try to get the existing value
    $existingValue = Get-ItemProperty -Path $registryPath -Name "ExtensionSettings" -ErrorAction SilentlyContinue

    # Initialize an empty hashtable for JSON
    $json = @{}

    # If there is existing data, convert from JSON
    if ($existingValue -and $existingValue.ExtensionSettings) {
        # Convert the existing REG_MULTI_SZ value (an array of strings) to a single string, then to JSON
        $jsonString = [String]::Join("`n", $existingValue.ExtensionSettings)
        try {
            # Convert JSON string to PSCustomObject and then to hashtable
            $jsonObject = ConvertFrom-Json -InputObject $jsonString
            $json = @{}
            foreach ($prop in $jsonObject.PSObject.Properties) {
                $json[$prop.Name] = $prop.Value
            }
        }
        catch {
            Write-Warning "Existing JSON data is corrupt or not in the expected format. Initializing with an empty JSON object."
            $json = @{}
        }
    }

    # Check if the specific key exists; if not, add it
    if (-not $json.ContainsKey($extensionKey)) {
        $json[$extensionKey] = $newData

        # Convert back to JSON string
        $updatedJsonString = ConvertTo-Json -InputObject $json -Depth 10

        # Update the registry value
        New-ItemProperty -Path $registryPath -Name "ExtensionSettings" -Value $updatedJsonString -PropertyType MultiString -Force

        # Output for confirmation
        Write-Output "Added new extension settings for '$extensionKey' at '$registryPath'"
    }
    else {
        # Output to indicate no change was made
        Write-Output "No update needed. '$extensionKey' settings already exist at '$registryPath'."
    }
}



# Apply for for both Chrome and Edge paths
Add-ExtensionToRegistry -registryPath "HKCU:\Software\Policies\Google\Chrome\ExtensionInstallForcelist" -extensionId "igjpcenkahclnlkcldhphacgmfilbefd"
Add-ExtensionToRegistry -registryPath "HKCU:\Software\Policies\Microsoft\Edge\ExtensionInstallForcelist" -extensionId "alhagkkmlflbnlckfifmlemhcmaaflon"

# Apply for Firefox
Update-FirefoxRegistryValue -registryPath "HKCU:\Software\Policies\Mozilla\Firefox"
