# macOS Setup Script

This script automates the setup of a new or reset macOS environment by installing essential software, configuring system settings, and personalizing the environment.

## Features

- Installs Homebrew and essential packages
- Configures Git with user details
- Installs Java JDK and Maven
- Sets up Oh My Zsh with useful plugins
- Configures macOS settings for a better user experience

## Requirements

- macOS
- Internet connection

## How to Run the Script

1. **Open Terminal**

2. **Clone the repository** (if applicable) or create a new file for the script:

   ```zsh
   git clone https://github.com/FainiDenis/SetupAndDeploy.git &&
   cd SetupAndDeploy/macOS
   ```
3. Before running the script, you may want to customize the following variables at the top of the script by running this command:
   ```zsh
   nano main_setup.sh
   ```
   - `GIT_USER_NAME` : Your user name for Git configuration.
   - `GIT_USER_EMAIL` : Your email for Git configuration.
   - `JAVA_VERSION` : Desired Java version.
   - `MAVEN_VERSION` : Desired Maven version.
   - **Add or remove Homebrew packages for your preferred applications.** in `install_packages.sh` script.

4. Run the script:
   ```zsh
   ./main_setup.sh
   ```

5. Follow any password prompts that appear during the installation process to enter your macbook sudo password.