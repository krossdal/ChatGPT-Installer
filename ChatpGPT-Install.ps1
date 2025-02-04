Write-Output "Starting ChatGPT installation script"

# Define download folder
$downloadFolder = "$PSScriptRoot"

# Ensure the folder exists
if (!(Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Path $downloadFolder -Force
}

# Define API URL
$postUrl = "https://store.rg-adguard.net/api/GetFiles"

# Generate a random boundary string
$boundary = [System.Guid]::NewGuid().ToString()

# Manually construct multipart/form-data body
$body = @"
--$boundary
Content-Disposition: form-data; name="type"

url
--$boundary
Content-Disposition: form-data; name="url"

https://apps.microsoft.com/detail/9nt1r1c2hh7j
--$boundary
Content-Disposition: form-data; name="ring"

Retail
--$boundary
Content-Disposition: form-data; name="lang"

is
--$boundary--
"@

# Set headers
$headers = @{
    "Content-Type" = "multipart/form-data; boundary=$boundary"
}

Write-Output "Getting package information from Microsoft Store"

# Send the POST request
$response = Invoke-WebRequest -Uri $postUrl -Method Post -Body $body -Headers $headers -UseBasicParsing

# Extract all valid download links
$pattern = '<a href="(http[^"]+)"[^>]*>([^<]+)</a>'
$matches = [regex]::Matches($response.Content, $pattern)

$filesToUpdate = @()

# Loop through matched links and download necessary files
Write-Output "Loop through matched links and download necessary files"
foreach ($match in $matches) {
    $url = $match.Groups[1].Value
    $filename = $match.Groups[2].Value
    
    # Match ChatGPT and Windows App Runtime (x64) files
    if ($filename -match "ChatGPT.*\.msixbundle") {
        $version = ($filename -split "_")[1]  # Extract version part
        $saveAs = "$downloadFolder\ChatGPT-$version.msixbundle"
    }
    elseif ($filename -match "WindowsAppRuntime.*x64.*\.msix") {
        $version = ($filename -split "_")[1]  # Extract version part
        $saveAs = "$downloadFolder\WindowsAppRuntime-$version.msix"
    } else {
        continue
    }
    
    # Check if file already exists and is up to date
    if (Test-Path $saveAs) {
        Write-Output "$saveAs already exists, skipping download."
        continue
    }
    
    $filesToUpdate += @{ Url = $url; Path = $saveAs }
}

# If updates are available, remove old installation and update
if ($filesToUpdate.Count -gt 0) {
    Write-Output "Updates available or ChatGPT not installed."

    # Close ChatGPT.exe to be able to delete old version and install new
    $processes = Get-Process -Name "ChatGPT" -ErrorAction SilentlyContinue
    if ($processes) {
        Write-Output "Closing ChatGPT.exe before update..."
        $processes | Stop-Process -Force
    }
    
    $chatGPTFolders = Get-ChildItem -Path "C:\\Program Files\\WindowsApps" -Filter "OpenAI.ChatGPT-*" -Directory -ErrorAction SilentlyContinue
    if($chatGPTFolders) {
        Write-Output "Removing old ChatGPT installations"
        foreach ($folder in $chatGPTFolders) {
            Write-Output "Taking ownership of: $($folder.FullName)"

            # Take Ownership
            takeown /F $folder.FullName /A /R /D Y

            # Grant Full Control to Administrators
            icacls $folder.FullName /grant Administrators:F /T /C /Q

            # Delete the folder
            Write-Output "Removing old installation: $($folder.FullName)"
            Remove-Item -Path $folder.FullName -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
    else{
        Write-Output "No previous installations found"
    }
    
    foreach ($file in $filesToUpdate) {
        Write-Output "Downloading: $($file.Path)"
        Invoke-WebRequest -Uri $file.Url -OutFile $file.Path
        
        Write-Output "Installing: $($file.Path)"
        Add-AppPackage -Path $file.Path
    }    
    Write-Output "All required files downloaded and installed!"
} else {
    Write-Output "No updates needed. ChatGPT is already up to date."
}
