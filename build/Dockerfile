#!/bin/bash

    # Ensure Nvidia container toolkit
    FROM nvidia/cuda:12.1.1-base-ubuntu20.04

    # Set ENV variables
    ENV LANG C.UTF-8
    ENV SHELL=/bin/bash
    ENV DEBIAN_FRONTEND=noninteractive

    ENV APT_INSTALL="apt-get install -y --no-install-recommends"
    ENV PIP_INSTALL="pip --no-cache-dir install --upgrade"

    RUN apt-get update && \
        $APT_INSTALL software-properties-common && \
        add-apt-repository -y ppa:deadsnakes/ppa && \
        apt purge -y python3.8-minimal && \
        apt autoremove -y && \
        apt-get update && \
        $APT_INSTALL \
            python3.10 \
            python3.10-dev \
            python3.10-distutils \
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
            build-essential && \
        ln -sf /usr/bin/python3.10 /usr/bin/python && \
        ln -sf /usr/bin/python3.10 /usr/bin/python3 && \
        curl https://bootstrap.pypa.io/get-pip.py | python3.10
    
    # Xformers is tightly bound to a specific Torch version - pulls as dependency
    ARG XFORMERS_VERSION=0.0.19
    
    # Get base Python packages
    RUN $PIP_INSTALL \
            xformers==${XFORMERS_VERSION} \
            torchvision \
            torchaudio \
            triton \
            nvidia-ml-py3 \
            python-dotenv \
            jupyterlab \
            ipython \
            ipykernel \
            ipywidgets \
            --extra-index https://download.pytorch.org/whl/cu118
    
    # Get the worker and its dependencies -
    # Our entrypoint will update this on boot (fast)
    
    ADD ./opt/horde /opt/horde
    
    ENV AIWORKER_CACHE_HOME=/notebooks/cache
    ENV PATH=$PATH:/opt/horde/bin:/notebooks/bin
    
    RUN /opt/horde/bin/install-horde.sh && \
        /opt/horde/bin/install-fixes.sh
    
    EXPOSE 8888 6006
    
    ENTRYPOINT ["/opt/horde/bin/entrypoint.sh"]
    
    # Copied from Paperspace base
        
    CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True