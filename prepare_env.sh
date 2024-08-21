#!/bin/sh

# Update package list and install required packages
sudo apt update && sudo apt install -y unzip zip android-sdk openjdk-17-jdk

# Set up Android SDK environment variables
export ANDROID_HOME=/usr/lib/android-sdk/
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# Function to install command line tools if not already installed
install_cmdline_tools() {
    if [ ! -f "$ANDROID_HOME/cmdline-tools/latest/bin/sdkmanager" ]; then
        echo "Command line tools not found. Downloading..."
        wget -q https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
        unzip -q commandlinetools-linux-11076708_latest.zip
        rm commandlinetools-linux-11076708_latest.zip
        echo "Installing command line tools..."
        cmdline-tools/bin/sdkmanager --install 'cmdline-tools;latest' --sdk_root=$ANDROID_HOME
        rm -rf cmdline-tools/
    else
        echo "Command line tools already installed."
    fi
}

# Install command line tools
install_cmdline_tools

# Install Maestro
echo "Installing Maestro..."
curl -Ls "https://get.maestro.mobile.dev" | bash

# Source .bashrc to apply changes
echo "Sourcing .bashrc..."
source $HOME/.bashrc

echo "Setup complete."
