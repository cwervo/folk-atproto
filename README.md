# Tcl ATProto Feed Fetcher

This script provides a Tcl-native way to fetch and process ATProtocol data, specifically user feeds from BlueSky (app.bsky.feed.getAuthorFeed).

## Benefits

For those familiar with Tcl and ATProto, this tool offers a lightweight method to interact with BlueSky/ATProto services directly using Tcl, without relying on external JavaScript/npm-based proxies or complex dependencies. It's a simple, scriptable solution for fetching feed data.

## Current Status & A Disclaimer

- The `atproto.tcl` script and broader ATProto library functionality are currently in (pre-alpha tbh) development.
- Currently I'm only providing fetching user feeds.
- **⚠️ This is an experimental repository. Use at your own risk.**

## Dependencies

*   **Tcl/Tk**: Version 8.6 or higher recommended.
    *   **http package**: Typically included with Tcl. Used for making HTTP(S) requests.
    *   **json package**: Part of Tcllib. Used for parsing JSON data. (Often available as `tcl-tcllib` or similar in package managers).
    *   **tls package**: Required for HTTPS communication. (Often available as `tcl-tls`, `tcltls`, or similar in package managers).

## Usage

### 1. Ensure Dependencies
Make sure Tcl is installed, along with the `json` (Tcllib) and `tls` packages. You can typically install these using your system's package manager. For example:
*   On Debian/Ubuntu: `sudo apt-get install tcl tcllib tcl-tls`
*   On Fedora: `sudo dnf install tcl tcllib tcl-tls`
*   On MacOS (using Homebrew): `brew install tcl-tk tls` (Tcllib is usually included with tcl-tk from Homebrew)

### 2. Running the Script Directly (Example Usage)
To see the script in action fetching a predefined user's feed:
```bash
tclsh atproto.tcl
```
This will execute the example feed fetching logic defined at the end of the `atproto.tcl` script for the user `bmann.ca`.

### 3. Using as a Library
To use the procedures in your own Tcl scripts, source the `atproto.tcl` file:
```tcl
source atproto.tcl
# Now you can call procedures like ::atproto::geturl and ::atproto::example_get_actor_feed
```
See the API section below for more details and examples.

## API

The script defines procedures within the `::atproto` namespace.

### `::atproto::geturl {url {_meta {}}}`
*   **Purpose**: Fetches the content of a given URL. Handles HTTPS.
*   **Parameters**:
    *   `url`: The URL to fetch.
    *   `_meta` (optional): If provided, this variable name will be used in the caller's scope to store metadata from the HTTP request (e.g., headers, status).
*   **Returns**: The data (body) from the URL as a string.
*   **Throws**: An error if the HTTP status is not "ok" (e.g., 404, 500).

### `::atproto::example_get_actor_feed {{actor_did "bmann.ca"}}`
*   **Purpose**: Fetches and prints a formatted feed for a given actor DID (Decentralized Identifier). This is an example function demonstrating the use of `geturl` and JSON parsing for a common ATProto task. It's primarily for demonstration.
*   **Parameters**:
    *   `actor_did` (optional): The DID of the actor whose feed is to be fetched. Defaults to "bmann.ca".
*   **Returns**: This procedure prints feed details directly to stdout. It does not return a structured Tcl value.

### Library Usage Example
```tcl
# Example of using atproto.tcl as a library
source atproto.tcl

# Ensure the json package is available for this example usage
package require json

set actor_did "did:plc:z72i7hdynmk6r22z27h6tvur" ;# Example: Jay Graber's DID
set feed_url "https://public.api.bsky.app/xrpc/app.bsky.feed.getAuthorFeed?actor=${actor_did}"

puts "Fetching feed for $actor_did using ::atproto::geturl"

try {
    set raw_feed_json [::atproto::geturl $feed_url]
    set parsed_feed [json::json2dict $raw_feed_json]

    # Now you can process $parsed_feed as needed
    # For example, print the number of feed items:
    if {[dict exists $parsed_feed feed]} {
        puts "Found [llength [dict get $parsed_feed feed]] items in the feed for $actor_did."
        # Further processing can be done here
        # foreach item [dict get $parsed_feed feed] {
        #     if {[dict exists $item post record text]} {
        #         puts "Post text: [dict get $item post record text]"
        #     }
        # }
    } else {
        puts "Could not find 'feed' key in the response for $actor_did."
    }

} trap {errMsg results} {
    puts stderr "Error fetching or parsing feed for $actor_did: $errMsg"
    # The 'results' variable is a dictionary containing error information
    # For example, to get the full error stack:
    # puts stderr "Error Info: [dict get $results -errorinfo]"
}
```

## How it Works (Internals)

The `atproto.tcl` script, when providing its library functions, performs the following:
1.  Requires necessary Tcl packages (`http`, `tls`, `json`) at the top level.
2.  Registers the `tls` package to handle HTTPS for the `http` package.
3.  The `::atproto::geturl` procedure fetches data from a given URL using the `::http` package.
4.  The `::atproto::example_get_actor_feed` procedure uses `::atproto::geturl` to fetch an actor's feed and `json::json2dict` to parse it, then prints a summary.
5.  When run directly, a block at the end of the file calls `::atproto::example_get_actor_feed` to demonstrate functionality.

This provides a basic framework for fetching and processing any ATProto XRPC endpoint that returns JSON.
