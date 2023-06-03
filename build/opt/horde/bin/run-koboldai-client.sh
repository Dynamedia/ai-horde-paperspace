#!/bin/bash

trap 'kill $(jobs -p)' EXIT

while getopts m: flag
do
    case "${flag}" in
        m) model="${OPTARG}";;
    esac
done

if [[ -z $model ]]
then
    model=$(grep -m1 "scribe_model" /opt/AI-Horde-Worker/bridgeData.yaml | cut -d: -f2)
fi

cd /opt/KoboldAI-Client
until micromamba run -n koboldai python aiserver.py --model ${model}; do
    echo "KoboldAI client crashed with exit code $?.  Respawning.." >&2
    sleep 1
done