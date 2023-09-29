#!/bin/bash

BRAVE_BASE_DIR=/home/$(whoami)/brave

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
echo "Extracting..."
dpkg-deb -x $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb $BRAVE_BASE_DIR
echo "Cleaning up..."
rm -i $BRAVE_BASE_DIR/brave-browser_$(echo $LATEST_RELEASE_VERSION)_amd64.deb
echo "Done."
