#!/bin/bash

# Missing symlink in Torch 2.0.0

if [ ! -f /usr/local/lib/python3.10/dist-packages/torch/lib/libnvrtc.so ]
then
    if [ -f /usr/local/lib/python3.10/dist-packages/torch/lib/libnvrtc-672ee683.so.11.2 ]
    then
        ln -s \
            /usr/local/lib/python3.10/dist-packages/torch/lib/libnvrtc-672ee683.so.11.2 \
            /usr/local/lib/python3.10/dist-packages/torch/lib/libnvrtc.so
    fi
fi

