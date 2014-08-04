#!/bin/bash

# Delete all existing generated code.
rm -f lib/gen/*.ml

# Recreate generated code.
code_gen/code_gen.byte < amqp0-9-1.xml

# Check that git detects no differences.
git status  # For the CI log.

if [ -n "$(git status -z lib/)" ]; then
    echo "Generated code does not match repo!"
    exit 1
fi
