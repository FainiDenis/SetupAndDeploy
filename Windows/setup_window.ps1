# This script sets up a Windows development environment using winget,
# downloads Maven, configures Git, and activate Windows

# Define versions for the packages and git username and email
$mavenVersion = "3.9.11"
$pythonVersion = "3.9"
$javaVersion = "24"
$gitUsername = "FainiDenis"
$gitEmail = "dtf8841@rit.edu"


# Check if winget is installed
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
    Write-Host "winget is not installed. Please install the App Installer from the Microsoft Store."
    exit
}

# Install all the packages

# Browsers
winget install --id Mozilla.Firefox -e                      # Firefox
winget install --id Google.GoogleDrive -e                   # Google Drive

# Python Packages
# Install Python packages using pip
pip install pytest                                          # Pytest for unit test

# Development Tools
winget install --id WiresharkFoundation.Wireshark -e        # Network Protocol Analyzer
winget install --id Python.Python.$pythonVersion -e         # Python 3.x
winget install --id Microsoft.WindowsSubsystemForLinux -e   # Windows Subsystem for Linux

# Git
winget install --id Git.Git -e                              # Git Version Control 

# Media
winget install --id VideoLAN.VLC -e                         # VLC Media Player
winget install --id MusicBrainz.Picard -e                   # MusicBrainz Picard

# Utilities + Other
winget install --id 7zip.7zip -e                             # 7-Zip File Archiver
winget install --id PuTTY.PuTTY -e                           # PuTTY
winget install --id Notepad++.Notepad++ -e                   # Notepad++
winget install --id Tailscale.Tailscale -e                   # Tailscale
winget install --id Greenshot.Greenshot -e                   # Greenshot
winget install --id Oracle.JDK.$javaVersion  -e              # Oracle JDK
winget install --id WinFsp.WinFsp -e                         # WinFsp
winget install --id MullvadVPN.MullvadVPN -e                # Mullvad VPN

# Office
# winget install --id Microsoft.Office.ProPlus -e
winget install --id Microsoft.Office365 -e                  # Microsoft Office 365

# Text Editors / IDEs / Readers
winget install --id Microsoft.VisualStudioCode -e            # Visual Studio Code
winget install --id Mobatek.MobaXterm -e                     # MobaXterm
winget install --id Adobe.Acrobat.Reader.64-bit -e           # Adobe Acrobat Reader

# Configure Git Global Settings
git config --global user.name "$gitUsername"         # Set Git username
git config --global user.email "$gitEmail"           # Set Git email

# Download maven
Invoke-WebRequest -Uri "https://dlcdn.apache.org/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip" -OutFile "C:\apache-maven-$mavenVersion-bin.zip"

# Extract maven
Expand-Archive -Path "C:\apache-maven-$mavenVersion-bin.zip" -DestinationPath "C:\Program Files\Apache\maven"

# Set environment variables for maven
[System.Environment]::SetEnvironmentVariable("MAVEN_HOME", "C:\Program Files\Apache\maven\apache-maven-$mavenVersion", [System.EnvironmentVariableTarget]::Machine)

# Update PATH environment variable
$env:Path += ";C:\Program Files\Apache\maven\apache-maven-$mavenVersion\bin"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

# Refresh PATH in current session
$env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

# Delete the maven zip file from the system
Remove-Item -Path "C:\apache-maven-$mavenVersion-bin.zip" -Force

# Microsoft Activation Scripts (MAS)
irm https://get.activated.win | iex # manually run this script to activate Windows
