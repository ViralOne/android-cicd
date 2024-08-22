# Android Emulator CI/CD Setup with Maestro

This repository contains a shell script that sets up a continuous integration and continuous deployment (CI/CD) environment for running Android emulator tests using Maestro. The script automates the process of installing the necessary tools, connecting to an Android device, installing an APK, and executing tests.

---

## Prerequisites

Before running the script, ensure you have the following:

- A Linux-based environment (Ubuntu preferred).
- A valid APK file (`wiki.apk`) located in the root directory of the project.

## Usage

The pipelines performs the following actions:

1. Install maestro mobile.dev app
2. Export maestro to PATH
3. **Check for ADB devices**: It lists connected ADB devices and filters for the device ID.
4. **Install the APK**: It installs the APK file specified in the script.
5. **Start screen recording**: It starts recording the screen for the duration of the tests.
6. **Run Maestro tests**: It executes the Maestro tests defined in `flow.yaml` and outputs the results in JUnit format to `result.xml`.
