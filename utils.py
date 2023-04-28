import nvidia_smi
import requests
import getpass
import ipywidgets as widgets
import click
import os
from dotenv import load_dotenv
import subprocess
import json
from collections import OrderedDict
from urllib.parse import urlparse

DOTENV = "/notebooks/.env"

models = None


def is_low_vram():
    nvidia_smi.nvmlInit()
    handle = nvidia_smi.nvmlDeviceGetHandleByIndex(0)
    info = nvidia_smi.nvmlDeviceGetMemoryInfo(handle)
    if round(info.total/1024/1024/1024) <= 12:
        return True
    return False


def set_api_key():
    api_key = getpass.getpass('Enter API key: ')

    if not is_key_valid(api_key):
        raise Exception("You have entered an invalid API key")    

    with open(DOTENV, 'w') as file:
        file.write("API_KEY=" + f'"{api_key}"')
    
    print('API key saved to ' + DOTENV)
    load_env_file()
                   
def is_key_valid(api_key):
    url = 'https://stablehorde.net/api/v2/find_user'
    headers = {'apikey': api_key}

    response = requests.get(url, headers = headers)

    if (response.status_code == 200):
        return True
    return False
                   

def has_saved_key():
    load_env_file()
    api_key = os.environ.get('API_KEY', False)

    if api_key:
        return is_key_valid(api_key)
    return False


def get_api_key():
    if not has_saved_key():
        set_api_key()
    else:
        load_env_file()
        
    return os.environ.get('API_KEY')
    

def load_env_file():
    subprocess.run(["touch", DOTENV])
    load_dotenv(DOTENV, override=True)
    
def get_all_models_data():
        url = "https://raw.githubusercontent.com/db0/AI-Horde-image-model-reference/main/stable_diffusion.json"
        response = requests.get(url)
        return response.json()
        
def get_active_models_data():
        url = "https://stablehorde.net/api/v2/status/models?type=image"
        response = requests.get(url)
        return response.json()
                   
def set_models():
    global models

    all_models = get_all_models_data()
    active_models = get_active_models_data()
    
    mdls = {}
    
    for k, v in all_models.items():
        model = {
            'name': k,
            'filename': v['config']['download'][0]['file_name'],
            'orig_filename': get_filename(v['config']['download'][0]['file_url']),
            'nsfw': v['nsfw'],
            'md5': v['config']['files'][0]['md5sum'],
            'sha256': v['config']['files'][0]['sha256sum'],
            'workers': 0,
            'queued': 0,
            'eta': 0
            }
        mdls[k] = model
    
    for item in active_models:
        model = None
        try:
            model = mdls[item['name']]
        except:
            continue
        
        model['workers'] = item['count']
        model['queued'] = item['queued']
        model['eta'] = item['eta']
        
    models = mdls
    
    
def get_filename(url):
    a = urlparse(url)     
    return os.path.basename(a.path)
    
    