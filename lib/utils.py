import os
import sys
import subprocess
import nvidia_smi
import requests
import getpass
import click
import json
import yaml
from collections import OrderedDict
from urllib.parse import urlparse
from dotenv import load_dotenv

DOTENV = "/notebooks/.env"
WORKER_YAML_PATH = '/notebooks/config/worker.yaml'
DREAMER_YAML_PATH = '/notebooks/config/dreamer.yaml'
ALCHEMIST_YAML_PATH = '/notebooks/config/alchemist.yaml'
SCRIBE_YAML_PATH = '/notebooks/config/scribe.yaml'
GPU_YAML_PATH = '/notebooks/config/gpu/'
BRIDGEDATA_PATH = '/opt/AI-Horde-Worker/bridgeData.yaml'

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
    
def get_gpu_code():
    gpu_model = subprocess.check_output(
    ["nvidia-smi", 
    "--query-gpu=name",
    "--format=csv,noheader"]
    ).decode(sys.stdout.encoding).strip()

    match gpu_model:
        case "NVIDIA RTX A4000":
            return "A4000"
        case "Quadro RTX 4000":
            return "RTX4000"
        case "Quadro RTX 5000":
            return "RTX5000"
        case "Quadro P5000":
            return "P5000"
        case _:
            return "default"

def get_yaml_config(path):
    with open(path, 'r') as file:
        return yaml.safe_load(file)
    
def write_yaml_config():
    worker_config = get_yaml_config(WORKER_YAML_PATH)
    dreamer_config = get_yaml_config(DREAMER_YAML_PATH)
    alchemist_config = get_yaml_config(ALCHEMIST_YAML_PATH)
    scribe_config = get_yaml_config(SCRIBE_YAML_PATH)
    gpu_config = get_yaml_config(f'{GPU_YAML_PATH}{get_gpu_code()}.yaml')
    
    merged_config = worker_config | dreamer_config | alchemist_config | scribe_config | gpu_config
    
    # Unique list via cast to set and back
    merged_config['models_to_load'] = list(set(dreamer_config['models_to_load'] + gpu_config['models_to_load']))
    merged_config['models_to_skip'] = list(set(dreamer_config['models_to_skip'] + gpu_config['models_to_skip']))
    merged_config['forms'] = list(set(alchemist_config['forms'] + gpu_config['forms']))
    
    merged_config['api_key'] = get_api_key()
    
    with open(BRIDGEDATA_PATH, 'w') as file:
        yaml.dump(merged_config, file)