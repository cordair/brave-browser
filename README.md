# brave-browser
Tool for managing Brave browser in a Debian system

## Explanation and purpose

The purpose of this tool is to mitigate the side effects of current available ways of installing
Brave Browser in a Debian system.

Currently, there exist three main ways of installing Brave:

1. Use of the [Brave official repository](https://brave.com/linux/#release-channel-installation)
2. Use of a [snap package](https://snapcraft.io/brave)
3. Use of [Flatpak](https://flathub.org/apps/com.brave.Browser) (unofficial)

As we can see, all of these ways go against Debian philosophy and run the risk of turning our system
into a [FrankenDebian](https://wiki.debian.org/DontBreakDebian).

As stated in that article:

> Repositories that can create a FrankenDebian if used with Debian Stable:
>
> - Debian testing release (currently trixie)
>
> - Debian unstable release (also known as sid)
>
> - Ubuntu, Mint or other derivative repositories are not compatible with Debian!
> - Ubuntu PPAs and other **repositories created to distribute single applications**
>
> **Some third-party repositories** might appear safe to use as they contain only packages that have no equivalent in Debian. However, there are no guarantees that any repository will not add more packages in future, leading to breakage.

Also, in my opinion, they overcomplicate things in the case of snaps and flatpak, which are heavier on resources.

With this tool I propose a different way of using Brave and with it a way of having an alternative to
a Chromium-based browser which can be modern, up-to-date and enhanced for privacy (or cryptocurrency).

I noticed that it's enough to extract the .deb package that can be found in the GitHub repositories,
so why make it more complicated?

This tool aims to make the process of downloading, verifying and extracting as automated and easy as
possible.

It uses the signing key that can be found at https://brave.com/signing-keys/

It fetches the latest version from the release channel in their GitHub repository https://github.com/brave/brave-browser/releases

It can be used both to download the package for the first time or to update a current version.

The tool follows the following steps:
1. It sets the default path where we'll keep our files (/home/username/brave), creating it if it doesn't exist.
2. It retrieves the public key, which I uploaded [to this same repository](https://github.com/cordair/brave-browser/blob/main/public_key_github_release_channel.asc) to make it easier to be retrieved (I couldn't find an official place that didn't require copy-pasting).
3. It gets the latest version number for the release channel at https://versions.brave.com/latest/release-linux-x64.version
4. It checks the version currently in used in the expected path. If it can't be found, it creates the base directory if needed and will download and install Brave for the first time.
5. It downloads, verifies the signature and checksums and finally extracts the .deb package.
6. It asks the user if downloaded files should be deleted (clean-up phase).
7. Finally, it asks if the user wants to keep the imported public keys for future verifications.

I've tested the script in different scenarios and it seems to work fine.
In principle, personal data, profiles and settings are kept at a different directory (/home/username/.config/BraveSoftware) by default so they aren't lost when we upgrade or even decide to install our browser in a different path.

I hope this can be helpful and bring something useful to the ecosystem.
Suggestions are very welcomed and you can let me know at my personal email or GitHub account.

