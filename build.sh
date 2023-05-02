#!/bin/bash

while getopts t:h: flag
do
    case "${flag}" in
        t) torch=${OPTARG};;
        h) horde=${OPTARG};;
    esac
done

if [ -z "$torch" ] || [ -z "$horde" ]
then
    echo "Please specify Torch version (-t) and Hordelib version (-h)"
    exit 1
else
    echo "Building for Torch Version $torch and Hordelib $horde";
    read -p "Continue (y/n)?" choice
    case "$choice" in 
      y|Y ) echo "Starting build...";;
      n|N ) echo "Cancelled build"; exit 0;;
      * ) echo "Invalid. Build cancelled"; exit 1;;
    esac
fi

VER_TAG=Torch_${torch}-Hordelib_${horde}

docker build --build-arg TORCH_VERSION=$torch --build-arg HORDELIB_VERSION=$horde -t dynamedia/aihorde-paperspace:latest -t dynamedia/aihorde-paperspace:$VER_TAG . &&
docker push dynamedia/aihorde-paperspace:$VER_TAG &&
docker push dynamedia/aihorde-paperspace:latest