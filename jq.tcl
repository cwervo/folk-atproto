# To use this module you need jq version 1.5rc1 or later installed.  However,
# jq 1.6 or later is highly recommended.  Due to a gsub() Unicode bug in earlier
# versions of jq (https://github.com/stedolan/jq/issues/1166), for example,
# fragments of CJK text in JSON may be missing or corrupted.

namespace eval jq {
    variable command jq
    variable prelude {
        def totcl:
            if type == "array" then
                # Convert an array to an object with the keys 0, 1, 2, ...
                # and process it as an object.
                [
                    range(0; length) as $i
                    | {
                        key: $i | tostring,
                        value: .[$i]
                    }
                ]
                | from_entries
                | totcl
            elif type == "object" then
                .
                | to_entries
                | map("{\(.key | totcl)} {\(.value | totcl)}")
                | join(" ")
            else
                tostring
                | gsub("{"; "\\{")
                | gsub("}"; "\\}")
            end;
    }
    variable version 0.7.0

    proc jq {filter data {options {-r}}} {
        variable command
        variable prelude

        exec $command {*}$options $prelude\n$filter << $data
    }

    proc jqf {filter file {options {-r}}} {
        variable command
        variable prelude

        exec $command {*}$options $prelude\n$filter $file
    }

    proc json2dict data {
        jq { . | totcl } $data
    }
}

