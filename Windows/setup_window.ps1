# This script sets up a Windows development environment using Chocolatey,
# downloads Maven, configures Git, and activates Windows

# Define versions for the packages and git username and email
$mavenVersion = "3.9.11"
$pythonVersion = "3.9"
$javaVersion = "24"
$gitUsername = "FainiDenis"
$gitEmail = "dtf8841@rit.edu"

# Function to check if a command exists
function check_exists_command {
    param (
        [string]$command
    )
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Host "$command is not installed. Please install it."
        exit
    }
}

# Function to install Chocolatey if not already installed
function install-chocolatey {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Chocolatey..."
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
    }
}

# Function to install packages using Chocolatey
function install_packages {
    param (
        [string[]]$packages
    )
    foreach ($package in $packages) {
        choco install $package -y
    }
}

# Function to configure Git
function configure-git {
    git config --global user.name $gitUsername
    git config --global user.email $gitEmail
}

# Function to download and set up Maven
function setup-maven {
    $mavenUrl = "https://dlcdn.apache.org/maven/maven-3/$mavenVersion/binaries/apache-maven-$mavenVersion-bin.zip"
    $mavenZipPath = "C:\apache-maven-$mavenVersion-bin.zip"
    $mavenInstallPath = "C:\Program Files\Apache\maven"

    Invoke-WebRequest -Uri $mavenUrl -OutFile $mavenZipPath
    Expand-Archive -Path $mavenZipPath -DestinationPath $mavenInstallPath

    # Set environment variables for Maven
    [System.Environment]::SetEnvironmentVariable("MAVEN_HOME", "$mavenInstallPath\apache-maven-$mavenVersion", [System.EnvironmentVariableTarget]::Machine)
    $env:Path += ";$mavenInstallPath\apache-maven-$mavenVersion\bin"
    [System.Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

    # Refresh PATH in current session
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)

    # Clean up
    Remove-Item -Path $mavenZipPath -Force
}

# Function to update the Windows system using PowerShell
function update_system {
    Write-Host "Updating system..."
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser  # Install the PSWindowsUpdate module
    Import-Module PSWindowsUpdate  # Import the module to use its cmdlets
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot  # Get and install all available updates, accepting all prompts and rebooting if necessary
}

# Function to remove unwanted apps
function remove_unwanted-apps {
    $unwantedApps = @(
        "*Teams*"
    )

    foreach ($app in $unwantedApps) {
        Get-AppxPackage -Name $app | Remove-AppxPackage
    }
}

# Function to set timezone
function set_timezone {
    Set-TimeZone -Name "Eastern Standard Time"
}

# Main script execution starts here

# Install Chocolatey if not already installed
install-chocolatey

# Check if choco is installed
check_exists_command -command "choco"

# Define the list of packages to install with Chocolatey
$chocoPackages = @(
    "firefox",                      # Firefox browser
    "wireshark",                   # Wireshark
    "python3",                     # Python (version 3.9, Chocolatey will handle specific version)
    "git",                         # Git
    "vlc",                         # VLC Media Player
    "picard",                      # MusicBrainz Picard
    "7zip",                        # 7-Zip
    "putty",                       # PuTTY
    "notepadplusplus",             # Notepad++
    "tailscale",                   # Tailscale
    "greenshot",                   # Greenshot
    "openjdk",                     # OpenJDK (Java, Chocolatey will handle specific version)
    "winfsp",                      # WinFsp
    "microsoft-office-deployment", # Microsoft Office 365
    "vscode",                      # Visual Studio Code
    "mobaxterm",                   # MobaXterm
    "googledrive",                 # Google Drive
    "libreoffice-fresh"           # LibreOffice
)

# set the timezone
set_timezone

# call the function to install packages
install_packages -packages $chocoPackages

# call the function to configure Git
configure-git

# call the function to download and set up maven
setup-maven

# call the function to remove unwanted apps
remove_unwanted_apps

# Microsoft Activation Scripts (MAS)
irm https://get.activated.win | iex # manually run this script to activate Windows

# call the function to update the system
update_system