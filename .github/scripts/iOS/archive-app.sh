#!/bin/bash

set -eo pipefail

xcodebuild -workspace './iOS/RSS App.xcworkspace' \
    -scheme 'RSS App' \
    -sdk iphoneos \
    -configuration Release \
    -archivePath 'build/iOS/RSS App.xcarchive' \
    clean archive | xcpretty

