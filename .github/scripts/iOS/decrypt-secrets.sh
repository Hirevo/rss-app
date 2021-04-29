#!/bin/bash

set -eo pipefail

gpg --quiet --batch --yes --decrypt --passphrase="${IOS_KEYS}" --output ./.github/secrets/RSS_App_iOS_Provisioning_Profile.mobileprovision ./.github/secrets/RSS_App_iOS_Provisioning_Profile.mobileprovision.gpg
gpg --quiet --batch --yes --decrypt --passphrase="${IOS_KEYS}" --output ./.github/secrets/RSS_App_iOS_Distribution.cer ./.github/secrets/RSS_App_iOS_Distribution.cer.gpg

mkdir -p ~/Library/MobileDevice/Provisioning\ Profiles

cp ./.github/secrets/RSS_App_iOS_Provisioning_Profile.mobileprovision ~/Library/MobileDevice/Provisioning\ Profiles/RSS_App_iOS_Provisioning_Profile.mobileprovision

security create-keychain -p "" build.keychain
security import ./.github/secrets/RSS_App_iOS_Distribution.cer -t agg -k ~/Library/Keychains/build.keychain -P "" -A

security list-keychains -s ~/Library/Keychains/build.keychain
security default-keychain -s ~/Library/Keychains/build.keychain
security unlock-keychain -p "" ~/Library/Keychains/build.keychain

security set-key-partition-list -S apple-tool:,apple: -s -k "" ~/Library/Keychains/build.keychain
