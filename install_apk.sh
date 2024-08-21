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

#Show adb devices
$ADB devices

adb install wiki.apk

echo "Starting maestro "
export MAESTRO_DRIVER_STARTUP_TIMEOUT=20000 # setting 20 seconds
maestro test -e APP_ID=org.wikipedia --no-ansi flow.yaml
