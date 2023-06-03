#!/bin/bash

trap 'kill $(jobs -p)' EXIT

branch="-b main"

while getopts qb: flag
do
    case "${flag}" in
        q) quiet="-q";;
        b) branch="-b ${OPTARG}";;
    esac
done

cd /notebooks
micromamba run -n jupyter python -c 'from lib import utils; utils.write_yaml_config()'

update-horde-worker.sh "${branch}"

run-alchemist-worker.sh "${quiet}" &

# Wait around to receive SIGINT
sleep infinity