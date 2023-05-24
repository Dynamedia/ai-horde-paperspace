#!/bin/bash

cd /opt/AI-Horde-Worker
git pull
# Ensure latest hordelib
pip --no-cache-dir install -U hordelib
pip --no-cache-dir install -r requirements.txt