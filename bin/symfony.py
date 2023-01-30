import os
import common, environment, composer

dataFile = {'name': '+Symfony', 'description': 'Help managing Symfony elements'}

runPath = os.getcwd()
runPathFolder = os.path.split(os.getcwd())
efdePath = f"{os.path.dirname(os.path.dirname(os.path.abspath(__file__)))}"

menu_option = [
    {"code": "createapp",   "title": "Create New App", 'description': 'Create a new symfony application'},
    {"code": "clone",   "title": "Clone My App", 'description': 'Clone from a git MyApp'},
    {"code": "console",   "title": "Console", 'description': 'Work with the symfony console'},
    {"code": "fixpermissions",   "title": "Fix permissions", 'description': 'Fix Permissions'},
]

def switch_option(code):
    if code in ['createapp','clone','console','fixpermissions']: 
        run_commands_options(code)
    else:
        print('You must select an option')

def run_commands_options(action, command = ''):
    if action == 'createapp': action_create_app()
    elif action == 'clone': action_clone_app()
    elif action == 'console': action_console()
    elif action == 'fixpermissions': action_fix_permissions()

def action_create_app(): 
    create_app_folder()
    if common.is_empty_directory('./app', True):
        start_docker()

        print(common.msgColor('Default will install symfony for microservice projects or apis','WARNING'))
        confirmwebapp = common.checkYesNo(common.msgColor('Do you want to install the packages for webapp?','WARNING'),'n')  

        appVersion = common.efde_file_env_read('app_version')
        run_command(f'composer create-project symfony/skeleton:"{appVersion}" .')
        
        if confirmwebapp: 
            run_command('composer require webapp')

        print(common.msgColor('\n############################################\n# EFDE created your project.\n# You can check it from http://localhost:80\n############################################','SUCCESS'))

def action_clone_app(): 
    create_app_folder()
    if common.is_empty_directory('./app', True):
        repository = input(common.msgColor('Enter the url of your repository: ','WARNING'))
        common.cli(f'git clone {repository} ./app')
        start_docker()
        composer.switch_option('install')

def action_console():
    values = ''
    command = 'bin/console'
    questionCommand = input(common.msgColor('Enter the command or press enter for more info: ','WARNING'))
    if questionCommand == '': 
        while True:
            search = input(common.msgColor('Enter what you are looking for or press enter for the full list: ','WARNING'))
            if search == '': 
                break
            else:
                if not values == '':
                    values = values + '|' + search
                else:
                    values = search
                continue
        
        if not values =='' :
            questionCommand = 'list | egrep --color=always "' + values + '"'
        else:
            questionCommand = 'list'

    command = command + ' ' + questionCommand
    run_command(command)

def action_fix_permissions(): 
    #ToDo: Review oficial documentation
    common.cli('sudo chown -R $USER:$USER ./app')

def run_command(command):
    common.cli(f"{common.command_docker_compose()} run --rm app_cli {command}", True)

def create_app_folder():
    if not common.exists_path('./app',True):
        common.cli(f'mkdir ./app',True)
        action_fix_permissions()

def start_docker():
    action_fix_permissions()
    environment.switch_option('apache')
    environment.management_container('up','', True)

## Install process
def get_data_version_environment():
    menu_current = [
        {'code': 5,  'title': 'Symfony 5.x', 'app_version': '5.*', 'php_version': '7.4', 'description': 'This version works with PHP-7.x'},
        {'code': 6,  'title': 'Symfony 6.x', 'app_version': '6.*', 'php_version': '8.1', 'description': 'This version works with PHP-8.x'}
    ]
    showHelper = True
    while True:
        common.menu_print(menu_current, dataFile, showHelper = True)
        opt=input(common.msgColor('\nEnter your option: ','SUCCESS'))

        if opt == 'q': exit()
        elif opt == 'r': 
            common.cli("clear")
            exit()
        elif opt == 'h':
            showHelper = not(showHelper)
            common.cli("clear")
        elif opt.isnumeric() and (int(opt) in range(0,len(menu_current))):
            code = menu_current[int(opt)]['code']
            return common.get_row_dictionary_for_key_value(menu_current,'code',code)
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue

    
def install_symfony():
    projectName = common.set_name_project()
    dataVersion = get_data_version_environment()
    
    projectPath = f"{runPath}/{projectName}"
    common.cli(f'mkdir {projectPath} ',True)
    common.cli(f'cp -rT {efdePath}/environments/symfony/ {projectPath}/',True)
    ## Update version PHP
    common.file_env_write(f"{projectPath}/.env",'PHP_VERSION', dataVersion['php_version'])
    ## efde.json
    efdeEnv = {'app_type': 'symfony', 'app_version': dataVersion["app_version"],'php_version': dataVersion['php_version']}
    common.efde_file_env_write(efdeEnv,f"{projectPath}/{common.efde_file_env_path()}")

    common.cli(f'cd {projectPath};efde')
    exit()

if __name__ == '__main__':

    showHelper = False
    while True:
        common.menu_print(menu_option, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','SUCCESS'))

        if opt == 'q': exit()
        elif opt == 'r': 
            common.cli('clear') 
            exit()
        elif opt == 'h': 
            showHelper = not(showHelper)
            common.cli('clear')
        elif opt.isnumeric() and (int(opt) in range(0,len(menu_option))):
            code = menu_option[int(opt)]['code']
            switch_option(code)

            input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
            common.cli('clear')
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
