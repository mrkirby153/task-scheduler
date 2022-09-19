#/bin/sh

echo "Updating protobufs"
protoc --elixir_out=plugins=grpc:lib proto/*.proto