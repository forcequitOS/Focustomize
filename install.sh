#!/bin/bash
# Focustomize Installer 1.0.6
# Define the download location and the URL for the latest release
DOWNLOAD_DIR=~/Downloads
ZIP_FILE=Focustomize.zip
APP_NAME=Focustomize.app
TEMP_DIR=$(mktemp -d)
GITHUB_RELEASE_URL="https://github.com/forcequitOS/Focustomize/releases/latest/download/Focustomize.zip"

# Checks if Focustomize has already been downloaded (this is a pretty lazy check)
if [ ! -f "$DOWNLOAD_DIR/$ZIP_FILE" ]; then
    echo "Downloading Focustomize..."
    # Downloads latest Focustomize
	curl -L -o "$DOWNLOAD_DIR/$ZIP_FILE" "$GITHUB_RELEASE_URL" > /dev/null 2>&1
    
    # Extracts zip to a temporary location
    unzip "$DOWNLOAD_DIR/$ZIP_FILE" -d "$TEMP_DIR" > /dev/null 2>&1
    rm "$DOWNLOAD_DIR/$ZIP_FILE"
else
	# Skips download (Since there's already a copy of Focustomize.zip locally)
    echo "Using pre-existing Focustomize archive"
    # Extracts zip
    unzip "$DOWNLOAD_DIR/$ZIP_FILE" -d "$TEMP_DIR" > /dev/null 2>&1
fi

if [ -d "$TEMP_DIR/$APP_NAME" ]; then
    echo "Installing Focustomize"
    # Copy to /Applications
    cp -R "$TEMP_DIR/$APP_NAME" /Applications/

    # Remove temporary location
    rm -rf "$TEMP_DIR"

	# Remove quarantine attribute (Thanks, Apple.)
    xattr -rd com.apple.quarantine /Applications/$APP_NAME

	# Ad-hoc signs app
    echo "Signing Focustomize"
    codesign -f -s - --deep /Applications/$APP_NAME > /dev/null 2>&1
	# Yippee.
    echo -e "\033[0;32mFocustomize has been installed successfully!\033[0m"
else
    echo "Error: Could not find Focustomize.app in the extracted contents."
fi
