#!/bin/sh

ADB="/usr/bin/adb"
APK="./wiki.apk"

echo "Installing APK"
$ADB install $APK

# echo "Starting screenrecord"
# $ADB emu screenrecord start --time-limit 460 maestro.webm
if [ ! -f "/usr/local/bin/maestro" ]; then
    export PATH="$PATH":"$HOME/.maestro/bin"
else
    echo "Maestro already installed"
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
adb connect "$device_id"

# Check if the connection was successful
if [ $? -eq 0 ]; then
    echo "Successfully connected to $device_id."
    adb install wiki.apk
else
    echo "Failed to connect to $device_id."
fi

echo "Starting maestro "
export MAESTRO_DRIVER_STARTUP_TIMEOUT=20000 # setting 20 seconds
maestro test -e APP_ID=org.wikipedia --no-ansi flow.yaml
