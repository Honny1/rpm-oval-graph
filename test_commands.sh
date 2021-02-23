#!/bin/sh
# Test script for testing command entry points

name="oval-graph"
test_file_src="./arf.xml"
tmp_dir_src="./tmp_data"
tmp_json_file_src="${tmp_dir_src}/data.json"

red="$(tput setaf 1)"
green="$(tput setaf 2)"
reset="$(tput sgr0)"

passed_msg="${green}passed${reset}"
failed_msg="${red}failed${reset}"

result=0

test_if_is_instaled_oval_graph() {
    if ! rpm -q --quiet $name; then
        echo "$name NOT installed"
        exit 1
    fi
}

report() {
    if [ $result -eq 0 ]; then
        printf "Result: %-70s %s\n" "$*" "$passed_msg"
    else
        printf "Result: %-70s %s\n\n" "$*" "$failed_msg"
    fi
}

test() {
    test_name="$1"
    command="$2"
    msg=""
    echo "Start: $test_name"
    $command >/dev/null
    if [ $? -eq 0 ]; then
        result=0
        msg="$test_name"
    else
        result=1
        msg="$test_name: $command"
    fi
    report "${msg}"
}

test_rise_error() {
    test_name="$1"
    command="$2"
    msg=""
    echo "Start: $test_name"
    $command >/dev/null 2>&1
    if [ $? -eq 2 ]; then
        result=0
        msg="$test_name"
    else
        result=1
        msg="$test_name: $command"
    fi
    report "${msg}"
}

clean() {
    echo "remove ${tmp_dir_src}"
    rm -rf ${tmp_dir_src}
}

help_tests() {
    test arf-to-graph-help "arf-to-graph -h"
    test arf-to-json-help "arf-to-json -h"
    test json-to-graph-help "json-to-graph -h"
}

bad_args_tests() {
    test_rise_error arf-to-graph-bad_arg "arf-to-graph -hello"
    test_rise_error arf-to-json-bad_arg "arf-to-json -hello"
    test_rise_error json-to-graph-bad_arg "json-to-graph -hello"
}

basic_test() {
    test run-arf-to-graph "arf-to-graph -o ${tmp_dir_src} ${test_file_src} fips"
    test run-arf-to-json "arf-to-json -o ${tmp_json_file_src} ${test_file_src} fips"
    test run-json-to-graph "json-to-graph -o ${tmp_dir_src} ${tmp_json_file_src} fips"
}

test_if_is_instaled_oval_graph
help_tests
bad_args_tests
basic_test

if [ "$1" = "--clean" ]; then
    clean
fi
