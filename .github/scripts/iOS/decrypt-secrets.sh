#!/bin/bash

set -eo pipefail

KEYCHAIN_PATH="${HOME}/Library/Keychains/build.keychain";
KEYCHAIN_PASSWORD="";

CERTIFICATE_PATH="./.github/secrets/RSS_App_iOS_Certificate.p12";
PROFILE_PATH="./.github/secrets/RSS_App_iOS_Provisioning_Profile.mobileprovision";

gpg --quiet --batch --yes --decrypt --passphrase="${IOS_KEYS}" --output "${PROFILE_PATH}" "${PROFILE_PATH}.gpg"
gpg --quiet --batch --yes --decrypt --passphrase="${IOS_KEYS}" --output "${CERTIFICATE_PATH}" "${CERTIFICATE_PATH}.gpg"

security create-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}";
security set-keychain-settings -lut 21600 "${KEYCHAIN_PATH}";
security unlock-keychain -p "${KEYCHAIN_PASSWORD}" "${KEYCHAIN_PATH}";

# import certificate to keychain
security import "${CERTIFICATE_PATH}" -P "${IOS_P12_PASSWORD}" -A -t cert -f pkcs12 -k "${KEYCHAIN_PATH}";
security list-keychain -d user -s "${KEYCHAIN_PATH}";

# apply provisioning profile
mkdir -p "${HOME}/Library/MobileDevice/Provisioning Profiles"
cp $PP_PATH "${HOME}/Library/MobileDevice/Provisioning Profiles"
