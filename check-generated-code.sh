#!/bin/bash

# Recreate generated code.
./regenerate-code.sh

# Check that git detects no differences.
git status  # For the CI log.

if ! git diff --quiet lib/; then
    echo ""
    echo "Generated code does not match repo!"
    echo ""
    git --no-pager diff lib/
    echo ""
    echo "Generated code does not match repo!"
    exit 1
fi
