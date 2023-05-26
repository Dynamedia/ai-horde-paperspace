<h1 align="center">
AI Horde Worker for Paperspace Gradient
</h1>

## Purpose
This repo allows users to generate images and contribute to the AI Horde using Paperspace Gradient (Pro/Growth).
If you do not have a Paperspace account you can [sign up here](https://console.paperspace.com/signup?R=FI2IEQI) for $10 free credit.

To learn more about AI Horde, see the [project website](https://aihorde.net/).

## Setup
Create a new notebook with the following advanced settings:
- Workspace URL: `https://github.com/Dynamedia/ai-horde-paperspace`
- Container Name: `dynamedia/ai-horde-paperspace:latest`

## Configuration
Once your container is running you will need to do a small amount of configuration in the file browser. You only need to do this once as all settings will be stored in your workspace for future use.

### Required

- Edit your worker name in config/worker.yaml
- Edit your dreamer name in config/dreamer.yaml

### Optional

- Set cache_home to '/notebooks/cache' in dreamer.yaml for persistent model storage. Beware - Paperspace may charge you for using too much storage. Check their T&C.

- Edit the files in config/gpu for better performance. Default settings are quite conservative and avoid picking jobs that will take a long time to process.

## Running

To run the worker you can either press run in dreamer.ipynb or open a terminal and type dreamer.sh

The first time you run the worker you will be asked for your AI Horde API key which will then be saved in /notebooks/.env - This is to avoid ever storing it where it could be accidentally viewed if the notebook is set to public.


## Managing your Worker

When the worker is running you may make changes to the live configuration by editing config/live/bridgeData.yaml

The dreamer.sh script will automatically respawn your worker if it should die for any reason.

You can use any of the AI Horde UI's to set or remove maintenance mode. I recommend [ArtBot](https://tinybots.net/artbot).