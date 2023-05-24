#!/bin/bash

    # Ensure Nvidia container toolkit
    FROM nvidia/cuda:11.8.0-base-ubuntu20.04

    # Set ENV variables
    ENV LANG C.UTF-8
    ENV SHELL=/bin/bash
    ENV DEBIAN_FRONTEND=noninteractive

    ENV APT_INSTALL="apt-get install -y --no-install-recommends"
    ENV PIP_INSTALL="pip --no-cache-dir install --upgrade"
    # Minimal base environment
    RUN echo \
        "deb http://ppa.launchpad.net/deadsnakes/ppa/ubuntu focal main" > \
        /etc/apt/sources.list.d/deadsnakes-ubuntu-ppa-focal.list && \
        apt-key adv --keyserver keyserver.ubuntu.com --recv-keys F23C5A6CF475977595C89F51BA6932366A755776  && \
        apt-get update && \
        $APT_INSTALL \
            python3.10 \
            python3.10-dev \
            python3.10-distutils \
            libgl1 \
            pkg-config \
            wget \
            git \
            curl \
            nano \
            build-essential && \
        ln -sf /usr/bin/python3.10 /usr/bin/python && \
        ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
        curl https://bootstrap.pypa.io/get-pip.py | python3.10
    
    # Xformers is tightly bound to a specific Torch version. It's all we need to require here.
    ARG XFORMERS_VERSION=0.0.20
    
    # 1. Get base Python packages required by paperspace
    # 2. Get horde notebook dependencies
    # 3. Pre-satisfy torch via xformers until Hordelib pins it correctly
    RUN $PIP_INSTALL \
            jupyterlab \
            ipython \
            ipykernel \
            ipywidgets && \
        $PIP_INSTALL \
            nvidia-ml-py3 \
            python-dotenv && \
        $PIP_INSTALL \
            xformers==${XFORMERS_VERSION} \
            --extra-index https://download.pytorch.org/whl/cu118
    
    # Get the worker and its dependencies -
    # Our entrypoint will update this on boot (fast)
    
    ADD ./opt/horde /opt/horde
    
    ENV AIWORKER_CACHE_HOME=/tmp
    ENV PATH=$PATH:/opt/horde/bin:/notebooks/bin
    
    RUN /opt/horde/bin/install-horde.sh && \
        /opt/horde/bin/install-fixes.sh
    
    EXPOSE 8888 6006
    
    # Copied from Paperspace base
        
    CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True