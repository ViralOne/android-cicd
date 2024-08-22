#!/bin/sh

# Define constants for ADB and APK paths
ADB="/usr/bin/adb"
APK="./wiki.apk"
MAESTRO_PATH="/usr/local/bin/maestro"
MAESTRO_BIN="$HOME/.maestro/bin"
TIMEOUT=30000

source ./install_apk.sh

# Check if Maestro is installed
if [ ! -f "$MAESTRO_PATH" ]; then
    echo "Maestro not found. Adding to PATH."
    export PATH="$PATH:$MAESTRO_BIN"
else
    echo "Maestro is already installed."
fi

# List connected ADB devices and filter for the device ID
device_id=$(adb devices | awk 'NR==2 {print $1}')

# Check if a device ID was found
if [ -z "$device_id" ]; then
    echo "No ADB devices found. Exiting."
    exit 1
fi

# Connect to the specified device
echo "Connecting to device $device_id..."
if adb connect "$device_id"; then
    echo "Successfully connected to $device_id."
else
    echo "Failed to connect to $device_id."
    exit 1
fi

# Install the APK
echo "Installing APK..."
if $ADB install "$APK"; then
    echo "APK installed successfully."
else
    echo "Failed to install APK."
    exit 1
fi

echo "Starting screenrecord"
$ADB emu screenrecord start --time-limit 460 maestro.webm

# Start Maestro test
echo "Starting Maestro..."
export MAESTRO_DRIVER_STARTUP_TIMEOUT=$TIMEOUT
if maestro test -e APP_ID=org.wikipedia --format=junit --output=result.xml --no-ansi flow.yaml; then
    echo "Maestro test completed successfully."
else
    echo "Maestro test failed."
    exit 1
fi
