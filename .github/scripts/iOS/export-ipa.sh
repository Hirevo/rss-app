#!/bin/bash

set -eo pipefail

xcodebuild -archivePath "${PWD}/build/iOS/RSS App.xcarchive" \
    -exportOptionsPlist 'iOS/exportOptions.plist' \
    -exportPath "${PWD}/build/iOS" \
    -allowProvisioningUpdates \
    -exportArchive | xcpretty
