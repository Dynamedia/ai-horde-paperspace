#!/bin/bash

trap 'kill $(jobs -p)' EXIT

while getopts q flag
do
    case "${flag}" in
        q) quiet="-q";;
    esac
done

cd /opt/AI-Horde-Worker
until micromamba run -n horde python bridge_stable_diffusion.py ${quiet}; do
    echo "Dreamer worker crashed with exit code $?.  Respawning.." >&2
    sleep 1
done