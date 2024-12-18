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

# List available AVDs and select the first one
AVD_NAME=$($ANDROID_HOME/emulator/emulator -list-avds | head -n 1)

if [ -z "$AVD_NAME" ]; then
    echo "No AVDs found. Exiting."
    exit 1
else
    echo "Using AVD: $AVD_NAME"
fi

# Start Android emulator
echo "Starting Android emulator..."
emulator -avd "$AVD_NAME" -no-window -no-audio -gpu swiftshader_indirect &

# Wait for emulator to boot with timeout
BOOT_TIMEOUT=300
BOOT_START_TIME=$(date +%s)
while true; do
    if adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
        echo "Emulator booted successfully"
        break
    fi
    
    CURRENT_TIME=$(date +%s)
    if [ $((CURRENT_TIME - BOOT_START_TIME)) -gt $BOOT_TIMEOUT ]; then
        echo "Timeout waiting for emulator to boot"
        exit 1
    fi
    
    echo "Waiting for emulator to boot..."
    sleep 5
done

# List connected ADB devices and filter for the device ID
device_id=$(adb devices | awk 'NR==2 {print $1}')

# Check if a device ID was found
if [ -z "$device_id" ]; then
    echo "No ADB devices found. Exiting."
    exit 1
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
adb emu screenrecord start --time-limit 460 maestro.webm

# Start Maestro test
echo "Starting Maestro..."
export MAESTRO_DRIVER_STARTUP_TIMEOUT=$TIMEOUT
if maestro test -e APP_ID=org.wikipedia --format=junit --output=result.xml --no-ansi "$MAESTRO_TESTS"; then
    echo "Maestro test completed successfully."
else
    echo "Maestro test failed."
    exit 1
fi
