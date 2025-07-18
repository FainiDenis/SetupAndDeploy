# Windows Development Environment Setup Script

This PowerShell script automates the setup of a Windows development environment by performing the following tasks:

1. **Checking for `winget`**: Ensures that `winget` is installed on your system.
2. **Installing Applications**: Utilizes `winget` to install essential applications, including browsers, development tools, text editors, media players, utilities, and Microsoft Office.
3. **Configuring Git**: Sets your Git username and email for version control.
4. **Downloading Maven**: Downloads and configures the specified version of Maven.
5. **Installing Python Packages**: Installs `pytest` using `pip` for testing purposes.
6. **Activating Windows**: Provides a command to activate your Windows installation.

## Configuration

Before running the script, customize the following variables to suit your needs:

- `$mavenVersion`: Specify the Maven version you want to install (default: `"3.9.11"`).
- `$pythonVersion`: Specify the Python version you want to install (default: `"3.9"`).
- `$javaVersion`: Specify the Java version you want to install (default: `"24"`).
- `$gitUsername`: Enter your Git username.
- `$gitEmail`: Enter your Git email address.

## Execution

To execute the script, follow these steps:

1. Open PowerShell as Administrator.
2. Run the script use command below:

   ```powershell
   iex (Invoke-WebRequest -Uri "https://raw.githubusercontent.com/FainiDenis/SetupAndDeploy/main/Windows/setup_window.ps1").Content


**Note**: Ensure you have administrative privileges for installations and modifications to your system.

