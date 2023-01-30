import common

dataFile = {'name': 'Composer', 'description': 'Help managing composer elements'}

menu_option = [
    {"code": "rmvendor", "title": "Remove vendor", 'description': 'Remove vendor'},
    {"code": "runscripts", "title": "Run scripts", 'description': 'Run Scripts'},
    {"code": "install", "title": "Install", 'description': 'Composer install'},
    {"code": "update", "title": "Update", 'description': 'update dependencys'},
]

def switch_option(code):
    if code in ['rmvendor', 'install','update','runscripts']: 
        run_commands_options(code)
    else:
        print('You must select an option')

def run_commands_options(action, command = ''):
    if action == 'rmvendor' : run_command('rm -rf vendor')
    elif action == 'install': run_command('composer install')
    elif action == 'update': run_command('composer update')
    elif action == 'runscripts':
        print(common.msgColor('Composer will run followed by what you type next.','WARNING'))
        action = input(common.msgColor('Enter the action or properties: ','WARNING'))
        run_command(f'composer {action}')
    else:
        print(common.msgColor('Error command.','DANGER'))

def run_command(command):
    common.cli(f'{common.command_docker_compose()} run --rm app_cli {command}', True)

if __name__ == '__main__':
    common.cli('clear')
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
