#!/bin/zsh
PROJECT_PATH="/Users/tajc/Library/Mobile Documents/com~apple~CloudDocs/Projects/Programming/Applications/Focustomize/Focustomize.xcodeproj"
ARCHIVE_PATH="/tmp/Focustomize.xcarchive"
APP_PATH="~/Downloads/Focustomize.app"
ZIP_PATH="~/Downloads/Focustomize.zip"

echo "Building Focustomize for Archival, please wait..."

# Build the project, skip code signing, and archive it
xcodebuild -project "$PROJECT_PATH" -scheme Focustomize -configuration Release -archivePath "$ARCHIVE_PATH" CODE_SIGN_STYLE=Manual archive

echo "Finishing up..."
# Copy the .app to Downloads and zip it
cp -R "$ARCHIVE_PATH/Products/Applications/Focustomize.app" "$APP_PATH"
rm -f "$ZIP_PATH" # Remove any existing Focustomize.zip
zip -r "$ZIP_PATH" "$APP_PATH"

echo "Done! Focustomize.app is ready for distribution!"