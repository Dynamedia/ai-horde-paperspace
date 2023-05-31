#!/bin/bash

cd /opt/AI-Horde-Worker
git pull
# Ensure latest hordelib
micromamba run -n horde pip --no-cache-dir install -U hordelib
micromamba run -n horde pip --no-cache-dir install -r requirements.txt
