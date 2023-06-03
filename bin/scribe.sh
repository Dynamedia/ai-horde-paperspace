#!/bin/bash

trap 'kill $(jobs -p)' EXIT

while getopts qm:b: flag
do
    case "${flag}" in
        q) quiet="-q";;
        m) model="-m ${OPTARG}";;
        b) branch="-b ${OPTARG}";;
    esac
done

cd /notebooks
micromamba run -n jupyter python -c 'from lib import utils; utils.write_yaml_config()'

update-horde-worker.sh "${branch}"
update-koboldai-client.sh

run-koboldai-client.sh &
run-scribe-worker.sh "${model}" &

# Wait around to receive SIGINT
sleep infinity