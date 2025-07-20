# This script sets up a Windows development environment using winget,
# downloads Maven, configures Git, and activate Windows

# Define versions for the packages and git username and email
$mavenVersion = "3.9.11"
$pythonVersion = "3.9"
$javaVersion = "24"
$gitUsername = "FainiDenis"
$gitEmail = "dtf8841@rit.edu"

# function to check if a command exists
function check_exists_command {
    param (
        [string]$command
    )
    if (-not (Get-Command $command -ErrorAction SilentlyContinue)) {
        Write-Host "$command is not installed. Please install it."
        exit
    }
}

# function to install packages using winget
function install_packages {
    param (
        [string[]]$packages
    )
    foreach ($package in $packages) {
        winget install --id $package -e
    }
}

# function to configure Git
function configure-git {
    git config --global user.name $gitUsername
    git config --global user.email $gitEmail
}

# function to download and set up Maven
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

# function to update the windows system using powershell
function update-system {
    Write-Host "Updating system..."
    Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser  # Install the PSWindowsUpdate module
    Import-Module PSWindowsUpdate  # Import the module to use its cmdlets
    Get-WindowsUpdate -AcceptAll -Install -AutoReboot  # Get and install all available updates, accepting all prompts and rebooting if necessary
}

# function to remvove unwanted apps
function remove-unwanted-apps {
    $unwantedApps = @(
        "*Microsoft3DViewer*",
        "*XboxGameCallableUI*",
        "*XboxGamingOverlay*",
        "*Xbox.TCUI*",
        "*XboxApp*",
        "*WindowsAlarms*",
        "*WindowsMaps*",
        "*WindowsPhone*",
        "*WindowsFeedbackHub*",
        "*Teams*",
        "*Solitaire*",
        "*LinkedIn*"
    )

    foreach ($app in $unwantedApps) {
        Get-AppxPackage -Name $app | Remove-AppxPackage
    }
}

# main script execution starts here

# check if winget is installed
check_exists_command -command "winget"

# define the list of packages to install
$wingetPackages = @(
    "Mozilla.Firefox",                      # Firefox browser
    "WiresharkFoundation.Wireshark",        # Wireshark
    "Python.Python.$pythonVersion",         # Python
    "Microsoft.WindowsSubsystemForLinux",   # WSL
    "Git.Git",                              # Git
    "VideoLAN.VLC",                         # VLC Media Player
    "MusicBrainz.Picard",                   # MusicBrainz Picard
    "7zip.7zip",                            # 7-Zip
    "PuTTY.PuTTY",                          # PuTTY
    "Notepad++.Notepad++",                  # Notepad++
    "Tailscale.Tailscale",                  # Tailscale
    "Greenshot.Greenshot",                  # Greenshot
    "Oracle.JDK.$javaVersion",              # Oracle JDK
    "WinFsp.WinFsp",                        # WinFsp
    "MullvadVPN.MullvadVPN",                # Mullvad VPN
    "Microsoft.Office365",                  # Microsoft Office 365
    "Microsoft.VisualStudioCode",           # Visual Studio Code
    "Mobatek.MobaXterm",                    # MobaXterm
    "Google.GoogleDrive",                   # Google Drive
    "Adobe.Acrobat.Reader.64-bit"           # Adobe Acrobat Reader
)

# call the function to install packages
install_packages -packages $wingetPackages

# call the function to configure Git
configure-git

# call the function to download and set up maven
setup-maven

# call the function to remove unwanted apps
remove-unwanted-apps

# Microsoft Activation Scripts (MAS)
irm https://get.activated.win | iex # manually run this script to activate Windows

# call the function to update the system
update-system
