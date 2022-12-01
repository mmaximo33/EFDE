import os, sys
sys.path.append(os.path.dirname(__file__))
import common as common

dataFile = {'name': '+Symfony', 'description': 'Help managing Symfony elements'}

pathDokerCompose = 'cd .. && '
pathDokerCompose = ''
menuReturn =  ''
menu_option = [
    {"code": "createapp",   "title": "Create app", 'description': 'Create a new symfony application'},
    {"code": "console",   "title": "Console", 'description': 'Work with the symfony console'},
    {"code": "fixpermissions",   "title": "Fix permissions", 'description': 'Fix Permissions'},
]

def switchOption(code):
    if code in ['createapp','console','fixpermissions']: 
        runCommands(code)
    else:
        print('You must select an option')

def runCommands(action, command = ''):
    commandDockerCompose = pathDokerCompose + "docker-compose run --rm app "    

    if action == 'createapp' :
        if(os.path.exists('./app')): 
            common.cli('cd ./app && ls')
            print(common.msgColor('Verify that the app directory exists','DANGER'))
        command = 'composer create-project symfony/website-skeleton .'
    elif action == 'console':
        values = ''
        command = 'bin/console'
        questionCommand = input(common.msgColor('Enter the command or press enter for more info: ','WARNING'))
        if questionCommand == '': 
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
            if not(values ==''): questionCommand = questionCommand + ' | egrep --color=always "' + values + '"'
        command = command + ' ' + questionCommand
    elif action == 'fixpermissions':
        fixPermissions()
        return

    common.cli(commandDockerCompose + ' ' + command)

#ToDo: Review oficial documentation
def fixPermissions():
    common.cli('sudo chown -R $USER:$USER ./app')

if __name__ == '__main__':
    
    showHelper = False
    while True:
        common.menu_print(menu_option, dataFile, showHelper)
        opt=input(common.msgColor('\nEnter your option: ','OKGREEN'))

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

            input(common.msgColor('\nPress enter to return to the menu','OKGREEN'))
            common.cli('clear')
        else:
            input(common.msgColor(f'The option "{opt}" is not in the list. Press enter to continue','DANGER'))
            common.cli('clear')
            continue