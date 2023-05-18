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
    echo "xformers version (-x) not specified."
    exit 1
else
    echo "Building for xformers Version $xformers";
fi

VER_TAG=xformers_${xformers}

docker build --build-arg XFORMERS_VERSION=$xformers -t dynamedia/ai-horde-paperspace:latest -t dynamedia/ai-horde-paperspace:$VER_TAG . &&
docker push dynamedia/ai-horde-paperspace:$VER_TAG &&
docker push dynamedia/ai-horde-paperspace:latest