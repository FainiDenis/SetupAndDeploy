#!/bin/zsh

# ============================================================================
# Development Environment Setup Script
# Configures Git, Java, Maven, and organizes folders
# ============================================================================

ZSHRC_FILE="$HOME/.zshrc"
GIT_CONFIG_FILE="$HOME/.gitconfig"
GIT_IGNORE_FILE="$HOME/.gitignore"
MAVEN_INSTALL_DIR="/usr/local/maven"
MAVEN_HOME="$MAVEN_INSTALL_DIR/apache-maven-$MAVEN_VERSION"
MAVEN_BIN_URL="https://dlcdn.apache.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.zip"

# Set JAVA_HOME in .zshrc
task_start "Setting JAVA_HOME"
JAVA_HOME_PATH=$(/usr/libexec/java_home 2>/dev/null)
if ! grep -q "export JAVA_HOME=" "$ZSHRC_FILE" 2>/dev/null; then
    if [ -w "$ZSHRC_FILE" ]; then
        echo "export JAVA_HOME=$JAVA_HOME_PATH" >> "$ZSHRC_FILE"
    else
        sudo sh -c "echo 'export JAVA_HOME=$JAVA_HOME_PATH' >> '$ZSHRC_FILE'"
    fi
    task_result "Changed" "JAVA_HOME set to $JAVA_HOME_PATH"
else
    task_result "OK" "JAVA_HOME already set"
fi

# Install Maven
task_start "Checking for Maven"
if ! command -v mvn &>/dev/null; then
    task_start "Downloading and installing Maven"
    if curl -L "$MAVEN_BIN_URL" -o /tmp/maven.zip; then
        sudo mkdir -p "$MAVEN_INSTALL_DIR" || { task_result "Failed" "Could not create Maven install directory"; exit 1; }
        
        if sudo unzip -q /tmp/maven.zip -d /tmp; then
            # Remove existing directory if it exists
            sudo rm -rf "$MAVEN_HOME"
            
            # Move the unzipped directory to the correct location
            sudo mv "/tmp/apache-maven-$MAVEN_VERSION" "$MAVEN_HOME" || { task_result "Failed" "Could not move Maven directory"; exit 1; }
            
            # Add Maven to PATH in .zshrc if not already present
            if ! grep -q "export MAVEN_HOME=$MAVEN_HOME" "$ZSHRC_FILE"; then
                echo "export MAVEN_HOME=$MAVEN_HOME" >> "$ZSHRC_FILE"
                echo 'export PATH="$MAVEN_HOME/bin:$PATH"' >> "$ZSHRC_FILE"
            fi
            
            # Clean up
            rm -f /tmp/maven.zip
            
            # Verify installation
            if "$MAVEN_HOME/bin/mvn" --version &>/dev/null; then
                task_result "Changed" "Maven $MAVEN_VERSION installed successfully"
            else
                task_result "Failed" "Maven installation verification failed"
                exit 1
            fi
        else
            task_result "Failed" "Failed to unzip Maven"
            exit 1
        fi
    else
        task_result "Failed" "Failed to download Maven"
        exit 1
    fi
else
    installed_version=$(mvn --version 2>/dev/null | head -n 1 | awk '{print $3}')
    task_result "OK" "Maven already installed (version $installed_version)"
fi

# Set up Git configuration
task_start "Setting up Git"
if [ ! -f "$GIT_CONFIG_FILE" ]; then
    task_start "Creating Git configuration"
    cat > "$GIT_CONFIG_FILE" << EOL
[user]
    name = $GIT_USER_NAME
    email = $GIT_USER_EMAIL
[core]
    editor = code --wait
EOL
    task_result "Changed" "Git configuration created"
else
    task_result "OK" "Git configuration already exists"
fi

# Set up Git ignore file
task_start "Setting up Git ignore file"
if [ ! -f "$GIT_IGNORE_FILE" ]; then
    task_start "Creating Git ignore file"
    cat > "$GIT_IGNORE_FILE" << EOL
# macOS specific files
.DS_Store
.AppleDouble
.LSOverride
._*
.Spotlight-V100
.Trashes
*.tmp
*.temp
*.bak
*.swp
*.log
node_modules/
__pycache__/
*.pyc
*.pyo
venv/
.env
.vscode/
*.orig
*.rej
*.swo
*.swp
*.zip
*.tar.gz
*.rar
EOL
    task_result "Changed" "Git ignore file created"
else
    task_result "OK" "Git ignore file already exists"
fi

# Organize folders
task_start "Organizing folders"
mkdir -p ~/Documents/{Projects,Personal,Work,Archives} &&
mkdir -p ~/Downloads/{Compressed,Media,Temporary} &&
task_result "Changed" "Folders organized"