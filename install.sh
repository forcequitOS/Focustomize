#!/bin/bash
# Variables
DOWNLOAD_DIR=~/Downloads
ZIP_FILE=Focustomize.zip
APP_NAME=Focustomize.app
TEMP_DIR=$(mktemp -d)
GITHUB_RELEASE_URL="https://github.com/forcequitOS/Focustomize/releases/latest/download/Focustomize.zip"
VERSION=1.2.0

# Litle installer header thing, since I'm cool.
echo -e "\033[1;38;5;93mFocustomize Installer v$VERSION\033[0m"

# Checks if Focustomize has already been downloaded (this is a pretty lazy check)
if [ ! -f "$DOWNLOAD_DIR/$ZIP_FILE" ]; then
    echo -e "\033[1;33m[INFO]\033[0m Downloading Focustomize..."
    # Downloads latest Focustomize
    curl -L -o "$DOWNLOAD_DIR/$ZIP_FILE" "$GITHUB_RELEASE_URL" > /dev/null 2>&1
    
    echo -e "\033[1;33m[INFO]\033[0m Extracting Focustomize archive..."
    # Extracts to temporary location
    unzip -qq "$DOWNLOAD_DIR/$ZIP_FILE" -d "$TEMP_DIR"
    rm "$DOWNLOAD_DIR/$ZIP_FILE"
else
    # Skips the download, just extracts (if Focustomize.zip already exists.)
    echo -e "\033[1;32m[SKIP]\033[0m Using pre-existing Focustomize archive."
    echo -e "\033[1;33m[INFO]\033[0m Extracting Focustomize archive..."
    unzip -qq "$DOWNLOAD_DIR/$ZIP_FILE" -d "$TEMP_DIR"
fi

# Install, un-quarantine, sign.
if [ -d "$TEMP_DIR/$APP_NAME" ]; then
    echo -e "\n\033[1;36m[INSTALL]\033[0m Installing Focustomize..."
    # Copy to /Applications
    cp -R "$TEMP_DIR/$APP_NAME" /Applications/

    # Nuke the temporary directory
    rm -rf "$TEMP_DIR"

    # Remove quarantine attribute
    echo -e "\033[1;36m[SECURITY]\033[0m Removing quarantine attribute..."
    xattr -rd com.apple.quarantine /Applications/$APP_NAME

    # Ad-hoc sign the app
    echo -e "\033[1;36m[SECURITY]\033[0m Signing Focustomize locally..."
    codesign -f -s - --deep /Applications/$APP_NAME > /dev/null 2>&1

    # Yippee.
    echo -e "\033[1;32mFocustomize has been installed successfully!\033[0m"
else
    echo -e "\n\033[1;31m[ERROR]\033[0m Could not find Focustomize.app in the extracted contents."
    echo -e "\033[1;31m[ERROR]\033[0m Please check the download source or the ZIP file contents."
fi
