#!/bin/bash
set -euo pipefail

move build
move sandbox clean
move sandbox publish
move sandbox run scripts/run.move --args "$@"
