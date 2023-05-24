#!/bin/bash

# Build for specific xformers because we do not want it
# downloading with its torch dependency at runtime
#- Too much time wasted.

while getopts x: flag
do
    case "${flag}" in
        x) xformers=${OPTARG};;
    esac
done

if [ -z "$xformers" ]
then
    xformers=0.0.20
fi

echo "Building for xformers Version $xformers";

VER_TAG=xformers_${xformers}

docker build --build-arg XFORMERS_VERSION=$xformers -t dynamedia/ai-horde-paperspace:latest -t dynamedia/ai-horde-paperspace:$VER_TAG . &&
docker push dynamedia/ai-horde-paperspace:$VER_TAG &&
docker push dynamedia/ai-horde-paperspace:latest
