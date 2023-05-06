#!/bin/bash

    FROM nvidia/cuda:11.8.0-base-ubuntu22.04

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
        libcairo2-dev \
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
        build-essential \
        python3 \
        python3-dev \
        python3-pip \
        python3-distutils && \
        ln -s /usr/bin/python3 /usr/bin/python
    
    ARG TORCH_VERSION
    
    # Get base Python packages
    RUN $PIP_INSTALL \
        torch==${TORCH_VERSION} \
        torchvision \
        torchaudio \
            --index-url https://download.pytorch.org/whl/cu118 && \
        ln -s \
            /usr/local/lib/python3.10/dist-packages/torch/lib/libnvrtc-672ee683.so.11.2 \
            /usr/local/lib/python3.10/dist-packages/torch/lib/libnvrtc.so && \
        $PIP_INSTALL \
        xformers \
        nvidia-ml-py3 \
        python-dotenv \
        jupyterlab \
        ipython \
        ipykernel  \
        ipywidgets \
            --extra-index-url https://download.pytorch.org/whl/cu118
    
    # Get hordelib and its dependencies
    
    ARG HORDELIB_VERSION
    
    RUN $PIP_INSTALL \
        rembg \
        unidecode \
        hordelib==${HORDELIB_VERSION} \
            --extra-index-url https://download.pytorch.org/whl/cu118 && \
        cd /opt/ && \
        $GIT_CLONE \
            -b comfy https://github.com/db0/AI-Horde-Worker
    
    # Set this to /notebooks/cache for persistence
    ENV AIWORKER_CACHE_HOME=/opt/AI-Horde-Worker/cache
            
    WORKDIR /opt/AI-Horde-Worker

    EXPOSE 8888 6006

    CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True