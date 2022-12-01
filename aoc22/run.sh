#!/bin/bash
set -euo pipefail

move build
move sandbox clean
move sandbox publish --ignore-breaking-changes
move sandbox run scripts/run.move --args "$@"
