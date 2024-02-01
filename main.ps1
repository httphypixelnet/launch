Write-Host "Minecraft Printer Edition"
Write-Host "Checking for java installation..."
$javaInstallDir = "C:\ProgramData\ETS\IBT2\java\17"
$launcherInstallDir = "C:\Users\$env:USERNAME\AppData\Roaming\.hmcl\bin"
$result = Invoke-WebRequest "https://discord.com" | Select-String -Pattern "Blocked"

if ($result) {
    $UseProxy = $true
} else {
    $UseProxy = $false
}
# Check if ETS and Java directories exist
if (-not (Test-Path -Path "C:\ProgramData\ETS\IBT2\")) {
    mkdir "C:\ProgramData\ETS\IBT2" > $null
}

if (-not (Test-Path -Path "C:\ProgramData\ETS\IBT2\java\")) {
    mkdir "C:\ProgramData\ETS\IBT2\java\17\" > $null
	Write-Host "Java not found, installing"
    $javaDownloadUrl = "https://static.houseofchupchik.net/OpenJDK17U-jre_x64_windows_hotspot_17.0.8.1_1.zip"
    $javaZipPath = Join-Path -Path $javaInstallDir -ChildPath "bin.zip"

    try {
        Invoke-WebRequest -Uri $javaDownloadUrl -OutFile $javaZipPath
        Expand-Archive -Path $javaZipPath -DestinationPath $javaInstallDir
		Write-Host "Install done!"
    } catch {
        Write-Host "Error downloading or extracting Java: $_.Exception.Message"
        # You may want to handle errors more gracefully here
		exit
    }
}

# Check if the launcher directory exists
if (-not (Test-Path -Path $launcherInstallDir)){
    mkdir $launcherInstallDir > $null
}

# Check if the launcher JAR exists and download if not
if (-not (Test-Path -Path "$launcherInstallDir\launcher.jar")){
    Write-Host "Downloading Minecraft Launcher"
    try {
        $curlPath = "C:\Windows\system32\curl.exe"
        $curlArgs = "-L", "-x", "54.191.4.93:1080", "-o", "$launcherInstallDir\launcher.jar", "--url", "https://static.houseofchupchik.net/cytvuybuni.mp4"
        Start-Process -FilePath $curlPath -ArgumentList $curlArgs -NoNewWindow -Wait

    } catch {
        Write-Host "Error downloading the Minecraft Launcher: $_.Exception.Message"
        # You may want to handle errors more gracefully here
		exit
    }
}

$javaArgs = "-jar", "$launcherInstallDir\launcher.jar"
$javaProxyArgs = "-DsocksProxyHost=54.191.4.93", "-DsocksProxyPort=1080", "-jar", "$launcherInstallDir\launcher.jar"
# Combine all the arguments into a single string

$javaArgsString = if($UseProxy){$javaProxyArgs -join ' '} else {$javaArgs -join ' '}

$launchCommand = "Start-Process -FilePath '$javaInstallDir\jdk-17.0.8.1+1-jre\bin\java.exe' -ArgumentList '$javaArgsString' -NoNewWindow -Wait"

# Start the PowerShell process with the combined command
Start-Process -FilePath powershell -ArgumentList "-NoProfile", "-Command", $launchCommand -WindowStyle Hidden -Wait