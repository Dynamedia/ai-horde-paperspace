#!/bin/bash

    # Ensure Nvidia container toolkit
    FROM nvidia/cuda:11.8.0-base-ubuntu20.04

    # Set ENV variables
    ENV LANG C.UTF-8
    ENV SHELL=/bin/bash
    ENV DEBIAN_FRONTEND=noninteractive
    ENV PATH=$PATH:/opt/horde/bin:/opt/micromamba/bin:/notebooks/bin
    ENV APT_INSTALL="apt-get install -y --no-install-recommends"
    ENV MAMBA_CREATE="micromamba --experimental create -y -c conda-forge"
    ENV PIP_INSTALL="pip --no-cache-dir install"
    
    # Force torch version to match in following mamba envs
    ARG TORCH_VERSION=2.0.1
    
    # Minimal base environment with micromamba
    RUN apt-get update && \
        $APT_INSTALL \
            pkg-config \
            libgl1 \
            parallel \
            git \
            curl \
            nano \
            build-essential && \
        mkdir -p /opt/micromamba && \
        cd /opt/micromamba && \
        curl -Ls https://micro.mamba.pm/api/micromamba/linux-64/latest | tar -xvj bin/micromamba && \
        micromamba shell init --shell=bash --prefix=~/micromamba && \
        $MAMBA_CREATE -y -n jupyter python=3.10 && \
        micromamba run -n jupyter $PIP_INSTALL \
            jupyterlab \
            jupyterlab-snippets \
            ipython \
            ipykernel \
            ipywidgets \
            click \
            nvidia-ml-py3 \
            python-dotenv
    
    # AI Horde Worker & KoboldAI Client
    RUN cd /opt && \
        git clone https://github.com/Haidra-Org/AI-Horde-Worker && \
        $MAMBA_CREATE -n horde python=3.10 && \
        micromamba run -n horde $PIP_INSTALL \
            --extra-index https://download.pytorch.org/whl/cu118 \
            torch==${TORCH_VERSION} \
            torchvision \
            torchaudio \
            triton \
            xformers && \
        micromamba run -n horde $PIP_INSTALL \
            -r /opt/AI-Horde-Worker/requirements.txt && \
        git clone https://github.com/KoboldAI/KoboldAI-Client && \
        cp /opt/KoboldAI-Client/requirements.txt /opt/KoboldAI-Client/reqs-mod.txt && \
        sed -i '/^torch.*[\W|=|>|<]*$/d' /opt/KoboldAI-Client/reqs-mod.txt && \
        $MAMBA_CREATE -n koboldai python=3.10 && \
        micromamba run -n koboldai $PIP_INSTALL \
            --extra-index https://download.pytorch.org/whl/cu118 \
            torch==${TORCH_VERSION} && \
        micromamba run -n koboldai $PIP_INSTALL \
            -r /opt/KoboldAI-Client/reqs-mod.txt
        
    ADD ./opt/horde /opt/horde
    
    ENV AIWORKER_CACHE_HOME=/tmp
    
    EXPOSE 8888 6006
    
    # Copied from Paperspace base
        
    CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True