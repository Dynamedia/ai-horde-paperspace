#!/bin/bash

    FROM ubuntu:22.04

    # Set ENV variables
    ENV LANG C.UTF-8
    ENV SHELL=/bin/bash
    ENV DEBIAN_FRONTEND=noninteractive

    ENV APT_INSTALL="apt-get install -y --no-install-recommends"
    ENV PIP_INSTALL="python3 -m pip --no-cache-dir install --upgrade"
    ENV GIT_CLONE="git clone --depth 10"

    # Base Ubuntu packages
    RUN apt-get update && \
        $APT_INSTALL \
        libgl1 \
        apt-utils \
        pkg-config \
        apt-transport-https \
        ca-certificates \
        wget \
        rsync \
        git \
        vim \
        mlocate \
        libssl-dev \
        curl \
        openssh-client \
        unzip \
        zip \
        nano \
        iputils-ping \
        cifs-utils \
        software-properties-common \
        python3 \
        python3-pip \
        python3-distutils
    
    # Get base Python packages
    RUN $PIP_INSTALL \
        torch \
        torchvision \
        torchaudio \
            --index-url https://download.pytorch.org/whl/cu118 && \
        $PIP_INSTALL \
        triton \
        xformers \
        nvidia-ml-py3 \
        python-dotenv \
        jupyterlab \
        ipython \
        ipykernel  \
        ipywidgets \
            --extra-index-url https://download.pytorch.org/whl/cu18
    
    # Get hordelib and its dependencies
    RUN $PIP_INSTALL \
        hordelib \
            --extra-index-url https://download.pytorch.org/whl/cu18 && \
        cd /opt/ && \
        $GIT_CLONE \
            -b comfy https://github.com/db0/AI-Horde-Worker
            
    WORKDIR /opt/AI-Horde-Worker


    EXPOSE 8888 6006


    CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True
