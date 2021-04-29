#!/bin/bash

set -eo pipefail

xcodebuild -archivePath 'build/iOS/RSS App.xcarchive' \
    -exportOptionsPlist 'iOS/exportOptions.plist' \
    -exportPath 'build/iOS' \
    -allowProvisioningUpdates \
    -exportArchive | xcpretty
