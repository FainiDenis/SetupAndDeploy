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
winget install --id Mozilla.Firefox -e

# Drive
winget install --id Google.GoogleDrive -e

# Development Tools
winget install --id WiresharkFoundation.Wireshark -e
winget install --id Python.Python.$pythonVersion -e

# Git
winget install --id Git.Git -e

# Text Editors / IDEs / Readers
winget install --id Adobe.Acrobat.Reader.64-bit -e
winget install --id Microsoft.VisualStudioCode -e
winget install --id Mobatek.MobaXterm -e

# Media
winget install --id VideoLAN.VLC -e

# Utilities + Other
winget install --id 7zip.7zip -e
winget install --id PuTTY.PuTTY -e
winget install --id Notepad++.Notepad++ -e
winget install --id Tailscale.Tailscale -e
winget install --id Greenshot.Greenshot -e
winget install --id Oracle.JDK.$javaVersion  -e
winget install --id WinFsp.WinFsp -e

# Office
# winget install --id Microsoft.Office.ProPlus -e
winget install --id Microsoft.Office365 -e

# Python Packages
# Install Python packages using pip
pip install pytest

# Configure Git Global Settings
git config --global user.name "$gitUsername"
git config --global user.email "$gitEmail"

# Download maven
Invoke-WebRequest -Uri "https://dlcdn.apache.org/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip" -OutFile "C:\apache-maven-$mavenVersion-bin.zip"

# Extract maven
Expand-Archive -Path "C:\apache-maven-$mavenVersion-bin.zip" -DestinationPath "C:\Program Files\Apache\maven"

# Set environment variables for maven
[System.Environment]::SetEnvironmentVariable("MAVEN_HOME", "C:\Program Files\Apache\maven\apache-maven-$mavenVersion", [System.EnvironmentVariableTarget]::Machine)

# Update PATH environment variable
$env:Path += ";$env:MAVEN_HOME\bin"
[System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

# Microsoft Activation Scripts (MAS)
irm https://massgrave.dev/get | iex # manually run this script to activate Windows
