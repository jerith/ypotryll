#!/bin/bash -e

# Rebuild code generator.
pushd code_gen
make clean
make
popd

# Delete all existing generated code.
rm -f lib/gen/*.ml

# Recreate generated code.
code_gen/code_gen.byte < amqp0-9-1.xml

# Update mllib files.
code_gen/update_mllib.byte
