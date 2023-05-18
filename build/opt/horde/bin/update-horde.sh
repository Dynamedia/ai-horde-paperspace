#!/bin/bash

# just update hordelib and its dependencies. It will probably be ok.

cd /opt/AI-Horde-Worker
git pull
pip --no-cache-dir install -U hordelib