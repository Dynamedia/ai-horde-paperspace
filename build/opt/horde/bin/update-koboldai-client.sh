#!/bin/bash

branch=main

if [[ ! -z "${KOBOLDAI_CLIENT_BRANCH}" ]]
then
branch="${KOBOLDAI_CLIENT_BRANCH}"
fi

# -b flag has priority
while getopts b: flag
do
    case "${flag}" in
        b) branch="$OPTARG";;
    esac
done


echo "Updating KoboldAI Client (${branch})..."

cd /opt/KoboldAI-Client
git checkout ${branch}
git pull

cp requirements.txt reqs-mod.txt
sed -i '/^torch.*[\W|=|>|<]*$/d' reqs-mod.txt

micromamba run -n koboldai $PIP_INSTALL -r reqs-mod.txt
