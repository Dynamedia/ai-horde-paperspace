#!/bin/bash

# Initial install ignores AI-Horde-Worker/requirements.txt

cd /opt
git clone https://github.com/Haidra-Org/AI-Horde-Worker
cd /opt/AI-Horde-Worker
pip --no-cache-dir install -U gradio \
    pyyaml \
    unidecode \
    regex \
    rembg \
    pynvml \
    psutil \
    loguru \
    GitPython \
    clip-anytorch \
    diffusers \
    omegaconf \
    setuptools \
    hordelib