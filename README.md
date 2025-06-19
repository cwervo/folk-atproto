# Tcl ATProto Feed Fetcher

This script provides a Tcl-native way to fetch and process ATProtocol data, specifically user feeds from BlueSky (app.bsky.feed.getAuthorFeed).

## Benefits

For those familiar with Tcl and the ATProto space, this tool offers a lightweight method to interact with BlueSky/ATProto services directly using Tcl, without relying on external JavaScript/npm-based proxies or complex dependencies. It's a simple, scriptable solution for fetching feed data.

## Dependencies

*   **Tcl/Tk**: Version 8.6 or higher recommended.
    *   **http package**: Typically included with Tcl. Used for making HTTP(S) requests.
    *   **json package**: Part of Tcllib. Used for parsing JSON data. (Often available as `tcl-tcllib` or similar in package managers).
    *   **tls package**: Required for HTTPS communication. (Often available as `tcl-tls`, `tcltls`, or similar in package managers).

## Usage

1.  **Ensure Dependencies**: Make sure Tcl is installed, along with the `json` (Tcllib) and `tls` packages. You can typically install these using your system's package manager. For example:
    *   On Debian/Ubuntu: `sudo apt-get install tcl tcllib tcl-tls`
    *   On Fedora: `sudo dnf install tcl tcllib tcl-tls`
    *   On macOS (using MacPorts): `sudo port install tcl tcllib tcltls`
    *   On macOS (using Homebrew): `brew install tcl-tk tls` (Tcllib is usually included with tcl-tk from Homebrew)

2.  **Run the Script**:
    ```bash
    tclsh getProfile.tcl
    ```
    By default, the script fetches the feed for the user `bmann.ca`. You can modify the `getProfile.tcl` script to change the target user or customize data processing.

## How it Works

The `getProfile.tcl` script performs the following:
1.  Requires necessary Tcl packages (`http`, `tls`, `json`).
2.  Registers the `tls` package to handle HTTPS for the `http` package.
3.  Defines a `geturl` procedure to fetch data from a given URL, returning the response body.
4.  Calls `geturl` to fetch the `app.bsky.feed.getAuthorFeed` XRPC endpoint for a specified actor (e.g., `bmann.ca`) from `https://public.api.bsky.app`.
5.  Parses the JSON response into a Tcl dictionary.
6.  Iterates through the feed items, printing selected information from each post's record.

This provides a basic framework for fetching and processing any ATProto XRPC endpoint that returns JSON.
