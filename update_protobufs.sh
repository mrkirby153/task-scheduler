#/bin/sh

echo "Updating protobufs"

rm -rf lib/proto

pushd proto > /dev/null
buf generate
popd > /dev/null