#!/bin/bash

# Quick environment update to ensure latest features
# without doing a full image rebuild

/opt/horde/bin/update-horde.sh

exec "$@"