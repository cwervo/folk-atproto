package require http
package require json

proc geturl {url {_meta {}}} {
    if {$_meta ne ""} {
        upvar 1 $_meta meta
    }
    http::config -useragent moop
    set tok [::http::geturl $url]
    try {
        upvar 1 $tok state
        if {[set status [::http::status $tok]] ne "ok"} {
            error $status
        }
        set headers [dict map {key val} [::http::meta $tok] {
            set key [string tolower $key]
            set val
        }]
        return [::http::data $tok]
    } finally {
        set meta [array get $tok]
        ::http::cleanup $tok
    }
}

set bmannResponse [geturl http://localhost:3000/xrpc/app.bsky.feed.getAuthorFeed?actor=bmann.ca]
set parsed_data [json::json2dict $bmannResponse]

set feed [dict get $parsed_data feed]

puts [llength $feed]

foreach post_item $feed {
    set post_content [dict get $post_item post]
    set record [dict get $post_content record]
    set keys [dict keys $record]

    puts "------------------------------"
    puts "post keys: $keys"

    set desired_record_keys {createdAt embed langs text $type facets}

    foreach k $keys {
        if {[lsearch -exact $desired_record_keys $k] != -1} {
            puts "$k: [dict get $record $k]"
        }
    }
    puts $record
    if {[dict exists $post_item reason]} {
        puts "Reason: [dict get $post_item reason]"
    }
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts "&&&&&&&&&&&&&&"
}
