#!/bin/sh

# Define constants for ADB and APK paths
APK="./wiki.apk"
MAESTRO_BIN="$HOME/.maestro/bin"
MAESTRO_TESTS="maestro/flow.yaml"
TIMEOUT=30000

if echo "$PATH" | grep -q ".maestro"; then
    echo ".maestro/bin is in the PATH."
else
    echo ".maestro/bin is not in the PATH."
    export PATH="$PATH:$MAESTRO_BIN"
fi
# List connected ADB devices and filter for the device ID
device_id=$(adb devices | awk 'NR==2 {print $1}')

# Check if a device ID was found
if [ -z "$device_id" ]; then
    echo "No ADB devices found. Exiting."
else
    echo "Device found: $device_id..."
fi

# Install the APK
echo "Installing APK..."
if adb -s "$device_id" install "$APK"; then
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
if maestro test -e APP_ID=org.wikipedia --format=junit --output=result.xml --no-ansi "$MAESTRO_TESTS"; then
    echo "Maestro test completed successfully."
else
    echo "Maestro test failed."
    exit 1
fi
