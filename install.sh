#!/bin/bash
# Focustomize Installer
# Define the download location and the URL for the latest release
DOWNLOAD_DIR=~/Downloads
ZIP_FILE=Focustomize.zip
APP_NAME=Focustomize.app
TEMP_DIR=$(mktemp -d)
GITHUB_RELEASE_URL="https://github.com/forcequitOS/Focustomize/releases/latest/download/Focustomize.zip"

# Just hides everything. Makes it look clean and cool.
exec 3>&1 4>&2
exec > >(grep -v -e "^" -e "^.*$") 2>&1

# Checks if Focustomize has already been downloaded (this is a pretty lazy check)
if [ ! -f "$DOWNLOAD_DIR/$ZIP_FILE" ]; then
    echo "Downloading Focustomize..."
    # Downloads latest Focustomize
    curl -L -o "$DOWNLOAD_DIR/$ZIP_FILE" "$GITHUB_RELEASE_URL"
    
    # Extracts zip to a temporary location
    unzip -qq "$DOWNLOAD_DIR/$ZIP_FILE" -d "$TEMP_DIR"
    rm "$DOWNLOAD_DIR/$ZIP_FILE"
else
	# Skips download
    echo "Using pre-existing Focustomize archive"
    # Extracts zip
    unzip -qq "$DOWNLOAD_DIR/$ZIP_FILE" -d "$TEMP_DIR"
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
    codesign -f -s - --deep /Applications/$APP_NAME
	# Yippee.
    echo -e "\033[0;32mFocustomize has been installed successfully!\033[0m"
else
    echo "Error: Could not find Focustomize.app in the extracted contents."
fi

# Unhides everything.
exec 1>&3 2>&4
