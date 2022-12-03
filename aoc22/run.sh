#!/bin/bash
set -euo pipefail

INPUT_ADDR=0x00000000000000000000000000000000
CODE_ADDR=0x0000000000000000000000000000c0de

load_inputs() {
    local dir name day out
    dir=storage/$INPUT_ADDR/resources
    mkdir -p "$dir"
    for bcs in inputs/*.bcs; do
        name=$(basename "$bcs")
        day="${name%%.*}"
        out=$dir/$CODE_ADDR::$day::Input.bcs
        if [ ! -e "$out" ]; then
            cp "$bcs" "$out"
        fi
    done
}

day=$(printf '%02d' "$1")
move sandbox publish --ignore-breaking-changes
load_inputs
move sandbox run "storage/$CODE_ADDR/modules/d$day.mv" -- run
