#!/bin/bash



# ==================================================================
# Initial setup based on paperspace gradient base-image
# ------------------------------------------------------------------

    # Ubuntu 20.04 as base image
    FROM ubuntu:20.04
    RUN yes| unminimize

    # Set ENV variables
    ENV LANG C.UTF-8
    ENV SHELL=/bin/bash
    ENV DEBIAN_FRONTEND=noninteractive

    ENV APT_INSTALL="apt-get install -y --no-install-recommends"
    ENV PIP_INSTALL="python3 -m pip --no-cache-dir install --upgrade"
    ENV GIT_CLONE="git clone --depth 10"


# ==================================================================
# Tools
# ------------------------------------------------------------------

    RUN apt-get update && \
        $APT_INSTALL \
        apt-utils \
        gcc \
        make \
        pkg-config \
        apt-transport-https \
        build-essential \
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
        unrar \
        zip \
        csvkit \
        emacs \
        joe \
        jq \
        dialog \
        man-db \
        manpages \
        manpages-dev \
        manpages-posix \
        manpages-posix-dev \
        nano \
        iputils-ping \
        sudo \
        ffmpeg \
        libsm6 \
        libxext6 \
        libboost-all-dev \
        cifs-utils \
        software-properties-common


# ==================================================================
# Python
# ------------------------------------------------------------------

    #Based on https://launchpad.net/~deadsnakes/+archive/ubuntu/ppa

    # Adding repository for python3.10
    RUN add-apt-repository ppa:deadsnakes/ppa -y && \

    # Installing python3.10
        apt remove -y python3.8 && \
        $APT_INSTALL \
        python3.10 \
        python3.10-dev \
        python3.10-venv \
        python3-distutils-extra

    # Add symlink so python and python3 commands use same python3.10 executable
    RUN ln -s /usr/bin/python3.10 /usr/local/bin/python3 && \
        ln -s /usr/bin/python3.10 /usr/local/bin/python

    # Installing pip
    RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.10
    ENV PATH=$PATH:/root/.local/bin


# ==================================================================
# Installing CUDA packages (CUDA Toolkit 11.7.0)
# ------------------------------------------------------------------

    # Based on https://developer.nvidia.com/cuda-toolkit-archive
    # Based on https://developer.nvidia.com/rdp/cudnn-archive
    # Based on https://docs.nvidia.com/deeplearning/cudnn/install-guide/index.html#package-manager-ubuntu-install

    # Installing CUDA Toolkit
    RUN wget https://developer.download.nvidia.com/compute/cuda/11.7.0/local_installers/cuda_11.7.0_515.43.04_linux.run && \
        bash cuda_11.7.0_515.43.04_linux.run --silent --toolkit && \
        rm cuda_11.7.0_515.43.04_linux.run

    ENV PATH=$PATH:/usr/local/cuda-11.7/bin
    ENV LD_LIBRARY_PATH=/usr/local/cuda-11.7/lib64

    # Installing CUDNN
    RUN wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-ubuntu2004.pin && \
        mv cuda-ubuntu2004.pin /etc/apt/preferences.d/cuda-repository-pin-600 && \
        apt-get install software-properties-common dirmngr -y && \
        apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/3bf863cc.pub && \
        add-apt-repository "deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/ /" && \
        apt-get update && \
        apt-get install libcudnn8=8.5.0.*-1+cuda11.7 -y && \
        apt-get install libcudnn8-dev=8.5.0.*-1+cuda11.7 -y && \
        rm /etc/apt/preferences.d/cuda-repository-pin-600


# ==================================================================
# Horde AI requirements
# ------------------------------------------------------------------

    RUN $PIP_INSTALL \
        torch==1.13.1+cu117 \
        torchvision==0.14.1+cu117 \
        torchaudio==0.13.1 \
        xformers==0.0.16 \
        nataili>=0.3.3  \
        nvidia-ml-py3 \
        pillow==9.5.0 \
        triton \
        gradio \
        pyyaml \
        unidecode \
        regex \
        rembg \
        pynvml \
        psutil --extra-index-url https://download.pytorch.org/whl/cu117 && \


# ==================================================================
# JupyterLab
# ------------------------------------------------------------------

    # Based on https://jupyterlab.readthedocs.io/en/stable/getting_started/installation.html#pip

    $PIP_INSTALL jupyterlab==3.4.6 && \


# ==================================================================
# Additional Python Packages (left from base)
# ------------------------------------------------------------------

    $PIP_INSTALL \
        numpy==1.23.4 \
        scipy==1.9.2 \
        pandas==1.5.0 \
        cloudpickle==2.2.0 \
        scikit-image==0.19.3 \
        scikit-learn==1.1.2 \
        matplotlib==3.6.1 \
        ipython==8.5.0 \
        ipykernel==6.16.0 \
        ipywidgets==8.0.2 \
        python-dotenv \
        cython==0.29.32 \
        tqdm==4.64.1 \
        gdown==4.5.1 \
        xgboost==1.6.2 \
        seaborn==0.12.0 \
        sqlalchemy==1.4.41 \
        spacy==3.4.1 \
        nltk==3.7 \
        boto3==1.24.90 \
        tabulate==0.9.0 \
        future==0.18.2 \
        gradient==2.0.6 \
        jsonify==0.5 \
        opencv-python==4.6.0.66 \
        sentence-transformers==2.2.2 \
        wandb==0.13.4 \
        awscli==1.25.91 \
        jupyterlab-snippets==0.4.1 \
        tornado==6.1


# ==================================================================
# Installing JRE and JDK
# ------------------------------------------------------------------

    RUN $APT_INSTALL \
        default-jre \
        default-jdk


# ==================================================================
# CMake
# ------------------------------------------------------------------

    RUN $GIT_CLONE https://github.com/Kitware/CMake ~/cmake && \
        cd ~/cmake && \
        ./bootstrap && \
        make -j"$(nproc)" install


# ==================================================================
# Node.js and Jupyter Notebook Extensions
# ------------------------------------------------------------------

    RUN curl -sL https://deb.nodesource.com/setup_16.x | bash  && \
        $APT_INSTALL nodejs  && \
        $PIP_INSTALL jupyter_contrib_nbextensions \
                     jupyterlab-git \
                     widgetsnbextension && \
        jupyter contrib nbextension install --user  && \
        jupyter nbextension enable widgetsnbextension --user --py && \
        pip cache purge

# ==================================================================
# Get the AI Horde - Just pul main branch for now
# ------------------------------------------------------------------
    WORKDIR /usr/local/

    RUN git clone https://github.com/db0/AI-Horde-Worker


# ==================================================================
# Startup
# ------------------------------------------------------------------

    EXPOSE 8888 6006

    CMD jupyter lab --allow-root --ip=0.0.0.0 --no-browser --ServerApp.trust_xheaders=True --ServerApp.disable_check_xsrf=False --ServerApp.allow_remote_access=True --ServerApp.allow_origin='*' --ServerApp.allow_credentials=True
