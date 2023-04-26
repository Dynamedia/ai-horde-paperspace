import nvidia_smi
import requests
import getpass
import ipywidgets as widgets
import click

DOTENV = "/notebooks/.env" # for testing

def is_key_valid(api_key):
    url = 'https://stablehorde.net/api/v2/find_user'
    headers = {'apikey': api_key}

    response = requests.get(url, headers = headers)

    if (response.status_code == 200):
        return True
    return False

def is_low_vram():
    nvidia_smi.nvmlInit()
    handle = nvidia_smi.nvmlDeviceGetHandleByIndex(0)
    info = nvidia_smi.nvmlDeviceGetMemoryInfo(handle)
    if round(info.total/1024/1024/1024) <= 12:
        return True
    return False


def set_worker_details():
    api_key = getpass.getpass('Enter API key: ')

    if not is_key_valid(api_key):
        raise Exception("You have entered an invalid API key")
    print("API key is valid...")
    
    worker_name = input('Enter Worker Name: ')
    
    nsfw = click.confirm('Allow NSFW?', default=True)


    with open(DOTENV, 'w') as file:
        file.write("API_KEY=" + f'"{api_key}"' + "\n" + 
               "WORKER_NAME=" + f'"{worker_name}"' + "\n" +
                "NSFW=" + f"{nsfw}")
    
    print('Worker details saved to ' + DOTENV)
    
    print('There is no need to re-run this cell unless you want to change your worker')