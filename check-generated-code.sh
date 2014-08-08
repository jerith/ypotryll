#!/bin/bash

# Recreate generated code.
./regenerate-code.sh

# Check that git detects no differences.
git status  # For the CI log.

if [ -n "$(git status -z lib/)" ]; then
    echo "Generated code does not match repo!"
    exit 1
fi
