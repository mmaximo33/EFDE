import os, sys
sys.path.append(os.path.dirname(__file__))
import common as common
dataFile = {'name': 'Composer', 'description': 'Help managing composer elements'}

pathDokerCompose = 'cd .. && '
pathDokerCompose = ''
menuReturn =  ''
menu_option = [
    {"code": "rmvendor", "title": "Remove vendor", 'description': 'Remove vendor'},
    {"code": "install", "title": "Install dependency", 'description': 'Composer install'},
    {"code": "update", "title": "Update dependency", 'description': 'update dependencys'},
    {"code": "runscripts", "title": "Run scripts", 'description': 'Run Scripts'},
]

def switchOption(code):
    if code in ['createapp','console','fixpermissions']: 
        managementContainer(code)
    else:
        print('You must select an option')

def managementContainer(action, command = ''):
    commandDockerCompose = pathDokerCompose + "docker-compose run --rm app "    

    if action == 'createapp' : 
        command = 'composer create-project symfony/website-skeleton .'
    elif action == 'console':
        command = 'bin/console'
        questionCommand = input(common.msgColor('Enter the command or press enter for more info: ','WARNING'))
        if questionCommand == '': 
            values = ''
            while True:
                search = input(common.msgColor('Enter what you are looking for or press enter for the full list: ','WARNING'))
                if search == '': 
                    questionCommand = "list"
                    break
                else:
                    if not(values == ''):
                        values = values + '|' + search
                    else:
                        values = search
                    continue
            if not values =='': questionCommand = questionCommand + ' | egrep --color=always "' + values + '"'
        command = command + ' ' + questionCommand
    elif action == 'fixpermissions':
        fixPermissions()
        return

    common.cli(commandDockerCompose + ' ' + command,True)

def fixPermissions():
    common.cli('sudo chown -R $USER:$USER ./app')

if __name__ == '__main__':
    print(
        common.msgColor(
            f"-------------------------------\nIn construction\n-------------------------------",
            'INFO_CYAN'
        )
    )
    input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
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
            switchOption(code)

            input(common.msgColor('\nPress enter to return to the menu','SUCCESS'))
            common.cli('clear')
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue
