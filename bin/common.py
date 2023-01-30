import os, sys, subprocess, json
from pathlib import Path
from dotenv import load_dotenv

dataFile = {'name': 'common',
            'description': 'Contains elements to reuse in other files'}

configEnv = {
    'pathBin': './bin/',
    'efdeFileEnv': 'efde.json'
}

class bcolors:
    HEADER = '\033[95m'
    INFO = '\033[94m'
    INFO_CYAN = '\033[96m'
    SUCCESS = '\033[92m'
    WARNING = '\033[93m'
    DANGER = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'
    UNDERLINE = '\033[4m'


def msgColor(msg, decorate=''):
    if decorate == 'HEADER':
        return bcolors.HEADER + msg + bcolors.ENDC
    elif decorate == 'INFO':
        return bcolors.INFO + msg + bcolors.ENDC
    elif decorate == 'INFO_CYAN':
        return bcolors.INFO_CYAN + msg + bcolors.ENDC
    elif decorate == 'SUCCESS':
        return bcolors.SUCCESS + msg + bcolors.ENDC
    elif decorate == 'WARNING':
        return bcolors.WARNING + msg + bcolors.ENDC
    elif decorate == 'DANGER':
        return bcolors.DANGER + msg + bcolors.ENDC
    elif decorate == 'BOLD':
        return bcolors.BOLD + msg + bcolors.ENDC
    elif decorate == 'UNDERLINE':
        return bcolors.UNDERLINE + msg + bcolors.ENDC
    else:
        return msg


def checkYesNo(message, default='y'):
    valuesYes = {'yes', 'y'}
    valuesNo = {'no', 'n'}
    selectDefault = 'Y/n' if default.lower() in valuesYes else 'y/N'
    choice = input("%s (%s) " % (message, selectDefault))
    if choice == '':
        choice = default
    if choice.lower() in valuesYes:
        return True
    elif choice.lower() in valuesNo:
        return False
    else:
        sys.stdout.write("Please respond with 'YES' or 'NO' \n")
        checkYesNo(message)

def command_exists(command):
    try:
        subprocess.run(f'command -v {command}', shell=True, check=True)
        return True
    except subprocess.CalledProcessError:
        return False

def command_docker_compose():
    command="docker compose"
    return command

def menu_print(data, menuData=[], showHelper=False):
    print(
        msgColor(
            f"-------------------------------\n{menuData['name'].upper()}\n{menuData['description']}\n-------------------------------",
            'INFO_CYAN'
        )
    )
    print('Select an option \n')
    for key, val in enumerate(data):
        if not (showHelper):
            print(f"{'{:02d}'.format(key)}) {val['title']}")
        else:
            print(
                (f"{'{:02d}'.format(key)}) {val['title']} \t {val['description']}").expandtabs(25))

    print(
        msgColor('\nPress q:quit | r:retry | h:helper', 'WARNING')
    )


def cli(command, show=False):  # ToDo: Detect operating system and apply replacements example (ls | dir)
    if show:
        print(msgColor(
            msgColor(
                f'RUN Command \n{command}\n________________________',
                'INFO_CYAN'
            ), 'BOLD')
        )
    os.system(command)

def cliReturn(command, show=False):
    return subprocess.check_output(command, shell=True)

#########################################
# FOLDERS
def exists_path(path, debug = False):
    result = os.path.exists(path)
    if not result and debug:
        print(msgColor(f'The indicated path does not exist\n {path}','DANGER'))
    return result

def is_directory(directory, debug = False):
    result = exists_path(directory, debug)
    if not result:
        return result

    result = os.path.isdir(directory) 
    if not result and debug:
        print(msgColor(f'The given path is not a directory\n {directory}','DANGER'))

    return result

def is_empty_directory(directory, debug = False):
    result = is_directory(directory, debug)
    if not result:
        return False
    
    result = os.listdir(directory)
    if result and debug:
        print(msgColor(f'The directory is not empty. \n {directory}\n Content:','DANGER'))
        cli(f'cd {directory} && ls -la')

    return not result

#########################################
# FILES 
def file_create(pathName):
    cli(f'touch {pathName}')

def file_exists(path):
    return os.path.exists(path)

#########################################
# Reade write File

def write_json_file(data, file_path, indent = 2):
    """
    Write file.json
    :param data: {'name': 'Maximo', 'age': 33, 'country': 'Argentina'}
    :param file_path: 'path/example.json'
    :param indent: integer
    
    Usage
    write_json_file(data, file_path)
    """
    with open(file_path, 'w') as json_file:
        json.dump(data, json_file, indent = indent)

def read_json_file(file_path):
    """
    Read file.json
    :param file_path: 'path/example.json'

    data = read_json_file(file_path)
    print(data)
    Output: {'name': 'Maximo', 'age': 33, 'country': 'Argentina'}
    """
    with open(file_path, 'r') as json_file:
        data = json.load(json_file)
    return data

#########################################
# EFDE FILE ENV
def efde_file_env_path(): return (configEnv['efdeFileEnv'])

def efde_file_env_exists(path = efde_file_env_path()):
    return file_exists(path)

def efde_file_env_write(data, file_path = efde_file_env_path()):
    write_json_file(data, file_path)

def efde_file_env_read(variable = None):
    if (not efde_file_env_exists()):
        return
    if variable == '':
        print('Indicate the variable you want')
    
    data = read_json_file(efde_file_env_path())
    if not variable == None:
        return data[variable]
        
    return data

#########################################
# FILE ENV
def file_env_read(variable='', path = '.env'):
    if (not (file_exists(False))):
        return
    if (variable == ''):
        print('Indicate the variable you want')

    dotenv_path = Path(efde_file_env_path())
    load_dotenv(dotenv_path=dotenv_path)
    return (os.environ.get(variable))

def file_env_write(path, key, value):
    """
    Updates an environment variable with the value specified in the .env file.
    If the environment variable does not exist, a new one is created.
    :param path: path to the .env file
    :param key: environment variable name
    :param value: value of the environment variable
    """
    dotenv_path = Path(path)
    load_dotenv(dotenv_path=dotenv_path)

    with open(path, 'r') as f:
        lines = f.readlines()
    with open(path, 'w') as f:
        for line in lines:
            if not line.startswith(f"{key}="):
                f.write(line)
            else:
                f.write(f"{key}={str(value)}\n")

#########################################
# Installation process
def set_name_project():
    while True:
        projectName = input(msgColor('Enter the project name [my-project]\nProject Name: ','WARNING'))
        if projectName == '': continue
        return projectName

def get_row_dictionary_for_key_value(dictionary, key, value):
    for item in dictionary:
        if item[key] == value:
            return item
    return None

