#!/bin/bash

while getopts q flag
do
    case "${flag}" in
        q) quiet="-q";;
    esac
done

cd /notebooks
micromamba run -n jupyter python -c 'from lib import utils; utils.write_yaml_config()'

echo "Updating worker and hordelib..."
update-horde.sh

cd /opt/AI-Horde-Worker
until micromamba run -n horde python bridge_stable_diffusion.py ${quiet}; do
    echo "Dreamer crashed with exit code $?.  Respawning.." >&2
    sleep 1
done