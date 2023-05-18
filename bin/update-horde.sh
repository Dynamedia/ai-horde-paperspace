#!/bin/bash

cd /opt/AI-Horde-Worker
git pull
pip --upgrade hordelib \
    gradio \
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