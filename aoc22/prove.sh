#!/bin/bash

# Comment out all debug statements so the prover is happy
for f in sources/*move; do
    sed -i -e 's_^\s*debug_//PROVE\0_' -e 's_^\s*use std::debug_//PROVE\0_' "$f"
done
move prove "$@"
for f in sources/*move; do
    sed -i -e 's_^//PROVE__' "$f"
done
