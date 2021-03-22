#!/bin/bash

docker build -t com.github.jewertow/collisions:build -f Dockerfile.build .

docker container create --name builder com.github.jewertow/collisions:build
docker container cp builder:/tmp/target/ ./target/
docker container rm -f builder
