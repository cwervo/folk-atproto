package require http
package require tls
package require json

# Register HTTPS support for the http package
::http::register https 443 ::tls::socket

namespace eval ::atproto {
    namespace export geturl example_get_actor_feed

    proc geturl {url {_meta {}}} {
        if {$_meta ne ""} {
            upvar 1 $_meta meta
        }
        # Ensure http package is available in this proc's context if not already loaded globally
        # package require http ; # Usually not needed if loaded at top-level
        http::config -useragent "Tcl-ATProto-Client/0.1"
        set tok [::http::geturl $url]
        try {
            upvar 1 $tok state
            if {[set status [::http::status $tok]] ne "ok"} {
                error "HTTP Error: $status - [::http::error $tok]"
            }
            set headers [dict map {key val} [::http::meta $tok] {
                set key [string tolower $key]
                set val
            }]
            return [::http::data $tok]
        } finally {
            # Ensure meta is populated even on error, if possible
            if {[info exists tok]} {
                set meta [array get $tok]
                ::http::cleanup $tok
            }
        }
    }

    proc example_get_actor_feed {{actor_did "bmann.ca"}} {
        # Ensure json package is available
        # package require json ; # Usually not needed if loaded at top-level

        set service_url "https://public.api.bsky.app"
        set endpoint_url "${service_url}/xrpc/app.bsky.feed.getAuthorFeed?actor=${actor_did}"

        puts "Fetching feed for actor: ${actor_did} from ${service_url}"

        try {
            set apiResponse [geturl $endpoint_url]
            set parsed_data [json::json2dict $apiResponse]

            if {![dict exists $parsed_data feed]} {
                puts "Error: 'feed' key not found in response."
                puts "Raw response: $apiResponse"
                return
            }
            set feed [dict get $parsed_data feed]

            puts "Found [llength $feed] posts."

            foreach post_item $feed {
                # Basic data extraction, can be expanded
                if {[dict exists $post_item post record text]} {
                    set post_text [dict get $post_item post record text]
                    set post_date [dict get $post_item post record createdAt]
                    puts "------------------------------"
                    puts "Date: $post_date"
                    puts "Text: [string range $post_text 0 100]..." ;# Print snippet
                } elseif {[dict exists $post_item reason]} {
                     set reason_type [dict get $post_item reason \$type]
                     set reason_by [dict get $post_item reason by handle]
                     set reason_date [dict get $post_item reason indexedAt]
                     puts "------------------------------"
                     puts "Repost by $reason_by at $reason_date"
                     if {[dict exists $post_item post record text]} {
                        set post_text [dict get $post_item post record text]
                        set post_date [dict get $post_item post record createdAt]
                        puts "  Original Post Date: $post_date"
                        puts "  Original Text: [string range $post_text 0 100]..." ;# Print snippet
                     }
                } else {
                    puts "------------------------------"
                    puts "Post item does not contain standard text or reason structure."
                    # Optionally print the whole item for debugging
                    # puts $post_item
                }
                # puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" ; # Reduced verbosity
            }
        } trap {} {errMsg results} {
            puts stderr "Error fetching or processing feed for ${actor_did}: $errMsg"
            # Optionally print result dictionary for more details on error
            # puts stderr "Options: $results" ; # Or specific keys like [dict get $results -errorinfo]
        }
    }
}

# This block executes only when the script is run directly
if {[info exists argv0] && [string equal $argv0 [info script]]} {
    puts "Fetching feed for bmann.ca as an example:"
    ::atproto::example_get_actor_feed "bmann.ca"

    # Example for a different user
    # puts "\nFetching feed for did:plc:z72i7hdynmk6r22z27h6tvur (Jay Graber) as an example:"
    # ::atproto::example_get_actor_feed "did:plc:z72i7hdynmk6r22z27h6tvur"
}
