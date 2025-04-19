# Install Games script

A PowerShell script that install the games defined in the [games.txt](games.txt) file.

Everyone that needs this script usually runs:
1. Windows (Win10 at minimum)
2. Steam

## Using the script



Download the [install.ps1](install.ps1) script somewhere safe, then run it.

You can do it by using any of the following methods:
- Right-click and `Run with PowerShell`
- Open a PowerShell/Windows Terminal window and then
    1. `cd` to where you downloaded the script
    2. Run it with `.\install.ps1`


## Adding/Removing games

**Adding**

1. Find the App ID for the game
    You can use [SteamDB](https://steamdb.info) to find the `App ID`
2. Put it in the [games.txt](games.txt) file with `->` between the Name & App ID
    Example:
    ```
    Squad->393380
    ```
3. Commit to the repo for it to be shared

**Removing**

It's as simple as deleting the whole line from the file.

## How this script works

By default, this script will download the latest [games.txt](games.txt) file and tell the locally installeld Steam to install the games defined within.

However, you can provide the `-local` flag to download from a locally provided file.

This makes use of the [Steam Browser Protocol](https://developer.valvesoftware.com/wiki/Steam_browser_protocol).