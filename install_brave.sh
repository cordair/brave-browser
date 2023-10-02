#!/bin/bash

BRAVE_BASE_DIR=/home/$(whoami)/brave
BRAVE_PUBKEY_URL="https://raw.githubusercontent.com/cordair/brave-browser/main/public_key_github_release_channel.asc"

LATEST_RELEASE_VERSION=$(wget -q -O - https://versions.brave.com/latest/release-linux-x64.version)
echo "Latest release: $LATEST_RELEASE_VERSION" # debugging purposes

if [ -e $BRAVE_BASE_DIR/opt/brave.com/brave/brave ]; then
    LOCAL_BRAVE_VERSION=$($BRAVE_BASE_DIR/opt/brave.com/brave/brave --version | cut -d ' ' -f 3 | cut -c 5-)
    echo "Local version: $LOCAL_BRAVE_VERSION" # debugging purposes

    if [ $LOCAL_BRAVE_VERSION != $LATEST_RELEASE_VERSION ]; then
        echo "There's a new version of Brave!"
    else
        echo "Latest version of Brave already in use."
        exit 0
    fi
else # Brave couldn't be found in expected location
    echo "Brave browser couldn't be found in expected location."
    if [ ! -e $BRAVE_BASE_DIR ]; then
        mkdir $BRAVE_BASE_DIR # /home/user_name/brave
    fi
fi

# Download and extract
echo "Downloading latest release ($LATEST_RELEASE_VERSION) to $BRAVE_BASE_DIR"
wget -q -nc "https://github.com/brave/brave-browser/releases/download/v$(echo $LATEST_RELEASE_VERSION)/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb" -P $BRAVE_BASE_DIR

echo "Downloading and importing public key..."
wget -q -O - $BRAVE_PUBKEY_URL | gpg --quiet --import

if [ $? -ne 0 ]; then
    echo "There was a problem importing the public keys."
    echo "Brave browser will be extracted without verification of signatures."
else # verify signature
    wget -q -nc -P $BRAVE_BASE_DIR "https://github.com/brave/brave-browser/releases/download/v$(echo $LATEST_RELEASE_VERSION)/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb.sha256.asc"

    wget -q -nc -P $BRAVE_BASE_DIR "https://github.com/brave/brave-browser/releases/download/v$(echo $LATEST_RELEASE_VERSION)/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb.sha256"

    echo "Verifying signature..."
    gpg --quiet --verify $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb.sha256.asc
    if [ $? -ne 0 ]; then
        echo "Signature can't be verified or incorrect one found."
    fi
fi

echo "Verifying checksums..."
CHECKSUM=$(sha256sum $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb | cut -d ' ' -f 1)
echo "Computed: $CHECKSUM" # degugging purposes

OFFICIAL_CHECKSUM=$(cut -d ' ' -f 1 $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb.sha256)
echo "Official: $OFFICIAL_CHECKSUM"

if [ $CHECKSUM = $OFFICIAL_CHECKSUM ]; then
    echo "Checksums okay."
else
    echo "Checksums don't match. Try again."
    exit 1
fi

echo "Extracting..."
dpkg-deb -x $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb $BRAVE_BASE_DIR
echo "Cleaning up..."
rm -i $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb*

echo "Public key from brave-checksums-release@brave.com was imported to your keyring."
echo "It can be kept for future verifications or it can be deleted."
echo "Would you like to delete it? (y/n)"
read -t 20 answer

if [ answer = "y" ]; then
    gpg --delete-keys brave-checksums-release@brave.com
fi

echo "Done."
